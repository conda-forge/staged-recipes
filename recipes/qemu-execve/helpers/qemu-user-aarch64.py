import argparse
import asyncio
import contextlib
import os
import platform
import shutil
import signal
import subprocess
from typing import Protocol, Optional

from qemu.qmp import QMPClient


class QMPProtocol(Protocol):
    qmp: QMPClient


class ProcessManager:
    def __init__(self, pid_file: str = "qemu_pid.txt"):
        self.pid_file = pid_file
        
    def save_pid(self, pid: int):
        with open(self.pid_file, 'w') as f:
            f.write(str(pid))
            
    def read_pid(self) -> Optional[int]:
        try:
            with open(self.pid_file, 'r') as f:
                return int(f.read().strip())
        except (FileNotFoundError, ValueError):
            return None
            
    def cleanup_existing_process(self):
        if pid := self.read_pid():
            try:
                os.kill(pid, signal.SIGTERM)
                print(f"[Process]: Terminated existing QEMU process (PID: {pid})")
            except ProcessLookupError:
                pass
            except Exception as e:
                print(f"[Process]: Error terminating process: {e}")
            with contextlib.suppress(FileNotFoundError):
                os.remove(self.pid_file)


class QEMUSnapshotMixin(QMPProtocol):
    """Mixin class for QEMU snapshot management.

    Required attributes from parent class:
    - qmp: QMPClient instance
    """

    async def list_snapshots(self) -> str:
        """List all available snapshots in the VM."""
        try:
            response = await self.qmp.execute('human-monitor-command',
                                              {'command-line': 'info snapshots'})
            print("[QMP]: Available snapshots:")
            print(response)
            return response
        except Exception as e:
            print(f"[QMP]: Error listing snapshots: {e}")
            return ""

    async def save_snapshot(self, name: str) -> bool:
        try:
            print(f"[QMP]: Creating snapshot '{name}'...")
            await self.qmp.execute('human-monitor-command',
                                   {'command-line': f'savevm {name}'})
            print("[QMP]: Snapshot created successfully")
            return True
        except Exception as e:
            print(f"[QMP]: Error creating snapshot: {e}")
            return False

    async def load_snapshot(self, name: str) -> bool:
        try:
            print(f"[QMP]: Loading snapshot '{name}'...")
            await self.qmp.execute('human-monitor-command',
                                   {'command-line': f'loadvm {name}'})
            print("[QMP]: Snapshot loaded successfully")
            return True
        except Exception as e:
            print(f"[QMP]: Error loading snapshot: {e}")
            return False

    async def delete_snapshot(self, name: str) -> bool:
        try:
            print(f"[QMP]: Deleting snapshot '{name}'...")
            await self.qmp.execute('human-monitor-command',
                                   {'command-line': f'delvm {name}'})
            print("[QMP]: Snapshot deleted successfully")
            return True
        except Exception as e:
            print(f"[QMP]: Error deleting snapshot: {e}")
            return False

    async def snapshot_exists(self, name: str) -> bool:
        snapshots = await self.list_snapshots()
        return name in snapshots

    async def ensure_snapshot(self, name: str, setup_func) -> bool:
        if not await self.snapshot_exists(name):
            print(f"[QMP]: Snapshot '{name}' not found, creating...")
            await setup_func()
            return await self.save_snapshot(name)
        return True


class ARM64Runner(QEMUSnapshotMixin):
    DEFAULT_SNAPSHOT = "conda"

    def __init__(
            self,
            qemu_system,
            qcow2_path,
            socket_path,
            iso_image=None,
            ssh_port=10022,
    ):
        self.qemu_system = qemu_system
        self.iso_image = iso_image
        self.qcow2_path = qcow2_path
        self.socket_path = socket_path
        self.ssh_port = ssh_port
        self.qemu_process = None

        self.qmp = QMPClient('ARM64 VM')
        self.custom_iso_path = None
        self.process_manager = ProcessManager()

    def _cleanup_socket(self):
        """Clean up the socket file if it exists"""
        try:
            if os.path.exists(self.socket_path):
                os.unlink(self.socket_path)
                print(f"[Socket]: Removed existing socket file: {self.socket_path}")
        except Exception as e:
            print(f"[Socket]: Error cleaning up socket: {e}")

    def _build_qemu_command(self, load_snapshot=None):
        if not os.path.exists(self.qemu_system):
            raise FileNotFoundError(f"QEMU executable not found at {self.qemu_system}")

        socket_dir = os.path.dirname(self.socket_path)
        os.makedirs(socket_dir, exist_ok=True)

        cmd = [
            self.qemu_system,
            "-name", f"QEMU User ({os.path.basename(self.qemu_system)})",
            "-M", "virt,secure=on",
            "-cpu", "cortex-a57",
            "-m", "2048",
            "-nographic",
            "-boot", "menu=on",
        ]

        # Get paths for UEFI firmware
        qemu_dir = os.path.dirname(self.qemu_system)
        edk2_code = os.path.join(qemu_dir, "share/qemu/edk2-aarch64-code.fd")
        edk2_vars = os.path.join(qemu_dir, "../edk2-aarch64-vars.fd")

        # Add UEFI firmware if available
        if os.path.exists(edk2_code):
            cmd.extend([
                "-drive", f"if=pflash,format=raw,file={edk2_code},readonly=on"
            ])
            if os.path.exists(edk2_vars):
                cmd.extend([
                    "-drive", f"if=pflash,format=raw,file={edk2_vars}"
                ])

        # Drive configuration
        cmd.extend([
            "-drive", f"file={self.qcow2_path},format=qcow2"
        ])

        if (iso_to_use := self.custom_iso_path or self.iso_image) and not load_snapshot:
            cmd.extend([
                "-drive", f"file={iso_to_use},format=raw,readonly=on"
            ])
            # cmd.extend(["-cdrom", iso_to_use])

        # QMP/network configuration
        cmd.extend([
            "-qmp", f"unix:{self.socket_path},server,nowait",
            "-netdev", f"user,id=net0,hostfwd=tcp::{self.ssh_port}-:22",
            "-device", "virtio-net-pci,netdev=net0"
        ])

        if platform.machine() == 'arm64':
            cmd.extend(["-accel", "hvf"])
        else:
            cmd.extend(["-accel", "tcg,thread=single"])

        if load_snapshot:
            cmd.extend(["-loadvm", load_snapshot])

        return cmd

    async def _wait_for_socket(self, timeout: int = 30) -> bool:
        """Wait for QMP socket to become available"""
        start_time = asyncio.get_event_loop().time()
        while True:
            if os.path.exists(self.socket_path):
                try:
                    # Test if socket is actually ready
                    reader, writer = await asyncio.open_unix_connection(self.socket_path)
                    writer.close()
                    await writer.wait_closed()
                    print("[Socket]: Socket is ready for connection")
                    return True
                except Exception:
                    pass

            elapsed = asyncio.get_event_loop().time() - start_time
            if elapsed >= timeout:
                print(f"[Socket]: Timeout waiting for socket after {elapsed:.1f}s")
                return False

            if not self.qemu_process or self.qemu_process.returncode is not None:
                print("[Socket]: QEMU process is not running")
                return False

            await asyncio.sleep(1)
            if int(elapsed) % 5 == 0:
                print(f"[Socket]: Waiting for socket... ({int(elapsed)}s)")

    async def _connect_qmp(self) -> bool:
        """Establish QMP connection with retries"""
        try:
            print("[QEMU]: Waiting for QMP socket...")
            socket_timeout = 30
            start_time = asyncio.get_event_loop().time()

            while not os.path.exists(self.socket_path):
                if self.qemu_process.returncode is not None:
                    stdout, stderr = await self.qemu_process.communicate()
                    print(f"[QEMU] Process terminated:\nstdout: {stdout.decode()}\nstderr: {stderr.decode()}")
                    raise RuntimeError("QEMU process terminated unexpectedly")

                if asyncio.get_event_loop().time() - start_time > socket_timeout:
                    raise TimeoutError(f"Socket not created after {socket_timeout} seconds")

                await asyncio.sleep(1)

            await self.qmp.connect(self.socket_path)
            print("[QMP]: Connected to socket")

            await asyncio.sleep(1)
            with contextlib.suppress(Exception):
                await self.qmp.execute('qmp_capabilities')
                print("[QMP]: Capabilities negotiated")

            return True
        except Exception as e:
            print(f"[QMP]: Connection failed: {e}")
            await asyncio.sleep(2)
            return False

    async def create_alpine_overlay(self):
        """Create Alpine overlay with automation scripts"""
        ovl_dir = "ovl"
        os.makedirs(f"{ovl_dir}/etc/runlevels/default", exist_ok=True)
        os.makedirs(f"{ovl_dir}/etc/local.d", exist_ok=True)
        os.makedirs(f"{ovl_dir}/etc/apk", exist_ok=True)
        os.makedirs(f"{ovl_dir}/etc/auto-setup-alpine", exist_ok=True)

        # Enable default boot services
        open(f"{ovl_dir}/etc/.default_boot_services", 'w').close()

        # Enable local service
        if not os.path.exists(f"{ovl_dir}/etc/runlevels/default/local"):
            os.symlink("/etc/init.d/local", f"{ovl_dir}/etc/runlevels/default/local")

        # Create APK repositories file
        with open(f"{ovl_dir}/etc/apk/repositories", 'w') as f:
            f.write("""
/media/cdrom/apks
https://dl-cdn.alpinelinux.org/alpine/latest-stable/main
https://dl-cdn.alpinelinux.org/alpine/latest-stable/community
""")

        # Create our setup script
        with open(f"{ovl_dir}/etc/local.d/auto-setup-alpine.start", 'w') as f:
            f.write("""#!/bin/sh
set -e

# Setup SSH and Conda
apk update
# apk add openssh
# rc-update add sshd
echo 'root:alpine' | chpasswd
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
/etc/init.d/sshd start

# Get and install Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O /tmp/miniconda.sh
chmod +x /tmp/miniconda.sh
/tmp/miniconda.sh -b -p /root/miniconda
echo 'export PATH=/root/miniconda/bin:$PATH' >> /root/.bashrc

# Run only once
rm -f /etc/local.d/auto-setup-alpine.start
rm -f /etc/runlevels/default/local

timeout 300 setup-alpine -ef /etc/auto-setup-alpine/answers
rm -rf /etc/auto-setup-alpine
""")
        os.chmod(f"{ovl_dir}/etc/local.d/auto-setup-alpine.start", 0o755)

        # Create answers file
        with open(f"{ovl_dir}/etc/auto-setup-alpine/answers", 'w') as f:
            f.write("""
KEYMAPOPTS=none
HOSTNAMEOPTS=alpine
DEVDOPTS=mdev
INTERFACESOPTS="auto lo
iface lo inet loopback
auto eth0
iface eth0 inet dhcp"
TIMEZONEOPTS=none
PROXYOPTS=none
APKREPOSOPTS="-1"
SSHDOPTS=openssh
NTPOPTS=none
DISKOPTS=none
LBUOPTS=none
APKCACHEOPTS=none
""")

        # Create overlay tarball
        subprocess.run(["tar", "-czf", "alpine.apkovl.tar.gz", "-C", ovl_dir, "."], check=True)

        return "alpine.apkovl.tar.gz"

    async def create_custom_alpine_iso(self, original_iso, overlay_file) -> str:
        """Create custom Alpine ISO with overlay"""
        def remove_readonly(func, path, exc_info):
            """Error handler for shutil.rmtree to handle read-only files"""
            import stat
            os.chmod(path, stat.S_IWRITE)
            func(path)

        # Create mount point
        mount_point = "./alpine-mount"
        work_dir = "./alpine-work"
        device = None

        try:
            # Mount original ISO
            os.makedirs(mount_point, exist_ok=True)
            os.makedirs(work_dir, exist_ok=True)

            attach_output = subprocess.run(
                ["hdiutil", "attach", "-nomount", original_iso],
                check=True,
                capture_output=True,
                text=True
            ).stdout.splitlines()
            device = attach_output[0].split()[0]  # First line, first column (/dev/disk2)

            if not device:
                raise RuntimeError("Failed to find HFS partition in hdiutil output")
            print(f"[DEBUG] Attached ISO to device: {device}")

            subprocess.run([
                "mount",
                "-t", "cd9660",
                "-o", "ro",
                device,
                mount_point,
            ], check=True)

            # Copy contents to work dir
            for item in os.listdir(mount_point):
                src = os.path.join(mount_point, item)
                dst = os.path.join(work_dir, item)
                if os.path.isdir(src):
                    shutil.copytree(src, dst, dirs_exist_ok=True)
                    # Make copied directory and contents writable
                    for root, dirs, files in os.walk(dst):
                        for d in dirs:
                            os.chmod(os.path.join(root, d), 0o755)
                        for f in files:
                            os.chmod(os.path.join(root, f), 0o644)
                else:
                    shutil.copy2(src, dst)
                    os.chmod(dst, 0o644)

            # Add overlay file
            shutil.copy2(overlay_file, os.path.join(work_dir, "alpine.apkovl.tar.gz"))

            # Create new ISO
            custom_iso = "custom-alpine.iso"
            subprocess.run([
                "hdiutil", "makehybrid",
                "-o", custom_iso,
                "-hfs", "-joliet", "-iso", "-udf",
                "-default-volume-name", "ALPINE",
                work_dir
            ], check=True)

            subprocess.run(["umount", mount_point], check=True)

            return custom_iso

        finally:
            # Cleanup
            subprocess.run(["hdiutil", "detach", device], check=False)
            if os.path.exists(work_dir):
                shutil.rmtree(work_dir, ignore_errors=True,)
                              # onerror=remove_readonly)

    async def await_boot_sequence(self):
        """Wait for VM to boot and connect to QMP"""
        print("[QMP]: Waiting for QMP socket...")

        # Await creation of QMP socket
        retry_count = 0
        while not os.path.exists(self.socket_path):
            await asyncio.sleep(10)
            retry_count += 1
            if retry_count > 30:
                raise TimeoutError("QMP socket not ready after 30 seconds")

        # Wait for socket to be ready for connection
        await asyncio.sleep(2)

        print("[QMP]: Connecting to VM...")
        try:
            await self.qmp.connect(self.socket_path)
            print("[QMP]:   '-> Connected to QMP socket")

            with contextlib.suppress(Exception):
                print("[QMP]: Negotiating QMP capabilities... (May raise an exception)")
                await self.qmp.execute('qmp_capabilities')
                print("[QMP]:   '-> Capabilities negotiated")

        except Exception as e:
            raise Exception(f"[QMP]: Error connecting to VM: {e}")

        print("[QMP]: Waiting for VM to boot...")
        status = await self.qmp.execute('query-status')
        if status['status'] != 'running':
            raise RuntimeError(f"VM failed to start: {status}")

        print("[QMP]: VM is running, waiting for boot messages...")

        retry_count = 0
        boot_timeout = 10
        while retry_count < boot_timeout:
            try:
                info = await self.qmp.execute('query-name')
                if info:
                    print(f"[QMP]:   '-> VM has finished booting. VM name: {info.get('name', 'Unknown')}")
                    break
            except Exception as e:
                print(f"[Boot]: Error reading output: {e}")

            retry_count += 1
            await asyncio.sleep(30)

            # Check if process is still alive
            if self.qemu_process.returncode is not None:
                raise RuntimeError(f"QEMU process died during boot with code {self.qemu_process.returncode}")

        if retry_count == boot_timeout:
            raise TimeoutError(f"Boot sequence not completed after {30 * boot_timeout} seconds")

    async def execute_ssh_command(self, command):
        """Execute command via SSH"""
        print("[DEBUG] Checking QEMU network info...")
        try:
            netinfo = await self.qmp.execute('human-monitor-command',
                                             {'command-line': 'info network'})
            print(f"[DEBUG] QEMU network info: {netinfo}")
        except Exception as e:
            print(f"[DEBUG] QEMU network info error: {e}")

        ssh_key_path = "/Users/runner/.ssh/id_rsa"
        if not os.path.exists(ssh_key_path):
            keygen_cmd = [
                "ssh-keygen",
                "-t", "rsa",
                "-N", "",  # No passphrase
                "-f", ssh_key_path
            ]
            process = await asyncio.create_subprocess_exec(
                *keygen_cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            stdout, stderr = await process.communicate()
            print(f"[SSH]: Key generation output: {stdout.decode()}")

        for attempt in range(3):
            try:
                # Test SSH connection
                test_cmd = [
                    "ssh",
                    "-p", str(self.ssh_port),
                    "-i", ssh_key_path,
                    "-o", "StrictHostKeyChecking=no",
                    "-o", "UserKnownHostsFile=/dev/null",
                    "-o", "ConnectTimeout=10",
                    "root@localhost",
                    "echo test"
                ]

                process = await asyncio.create_subprocess_exec(
                    *test_cmd,
                    stdout=asyncio.subprocess.PIPE,
                    stderr=asyncio.subprocess.PIPE
                )
                stdout, stderr = await process.communicate()
                if process.returncode == 0:
                    break
            except Exception as e:
                print(f"[SSH]: Connection attempt {attempt + 1} failed: {e}")
            await asyncio.sleep(10)

        # Execute actual command
        ssh_cmd = [
            "ssh",
            "-p", str(self.ssh_port),
            "-i", ssh_key_path,
            "-o", "StrictHostKeyChecking=no",
            "-o", "UserKnownHostsFile=/dev/null",
            "root@localhost",
            command
        ]

        print(f"[Command]: Executing via SSH: {command}")
        try:
            process = await asyncio.create_subprocess_exec(
                *ssh_cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            stdout, stderr = await process.communicate()
            return stdout.decode(), stderr.decode(), process.returncode
        except Exception as e:
            print(f"[Command]: SSH Error: {e}")
            return "", str(e), 1

    async def start_vm(self, load_snapshot: Optional[str] = None) -> bool:
        """Start VM with proper cleanup and initialization"""
        # Cleanup any existing processes and sockets
        self.process_manager.cleanup_existing_process()
        self._cleanup_socket()

        cmd = self._build_qemu_command(load_snapshot)
        print(f"[QEMU]: Starting VM with command: {' '.join(cmd)}")

        try:
            self.qemu_process = await asyncio.create_subprocess_exec(
                *cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )

            if self.qemu_process.returncode is not None:
                stdout, stderr = await self.qemu_process.communicate()
                print(f"[QEMU] stdout: {stdout.decode()}")
                print(f"[QEMU] stderr: {stderr.decode()}")
                raise RuntimeError(f"QEMU process failed to start (code: {self.qemu_process.returncode})")

            self.process_manager.save_pid(self.qemu_process.pid)
            print(f"[Process]: QEMU started with PID {self.qemu_process.pid}")

            await asyncio.sleep(2)

            # Attempt QMP connection with retries
            for attempt in range(5):  # Increased retry attempts
                try:
                    if await self._connect_qmp():
                        print("[QMP]: Successfully connected and negotiated capabilities")

                        # Verify VM is running
                        status = await self.qmp.execute('query-status')
                        if status['status'] != 'running':
                            raise RuntimeError(f"VM is not running: {status}")

                        retry_count = 0
                        boot_timeout = 10
                        while retry_count < boot_timeout:
                            try:
                                info = await self.qmp.execute('query-name')
                                if info:
                                    print(
                                        f"[QMP]: VM has finished booting. VM name: {info.get('name', 'Unknown')}")
                                    break
                            except Exception as e:
                                print(f"[Boot]: Error reading output: {e}")

                            retry_count += 1
                            await asyncio.sleep(30)

                            # Check if process is still alive
                            if self.qemu_process.returncode is not None:
                                raise RuntimeError(
                                    f"QEMU process died during boot with code {self.qemu_process.returncode}")

                        if retry_count == boot_timeout:
                            raise TimeoutError(f"Boot sequence not completed after {30 * boot_timeout} seconds")

                        return True
                except Exception as e:
                    print(f"[QMP]: Connection attempt {attempt + 1} failed: {e}")
                    if attempt < 4:  # Don't sleep on last attempt
                        await asyncio.sleep(5)  # Increased delay between attempts

            raise ConnectionError("Failed to establish QMP connection after all attempts")

        except Exception as e:
            print(f"[Error]: Failed to start VM: {e}")
            if self.qemu_process and self.qemu_process.returncode is not None:
                stdout, stderr = await self.qemu_process.communicate()
                print("[QEMU] Process output:")
                print(f"stdout: {stdout.decode()}")
                print(f"stderr: {stderr.decode()}")
            await self.stop_vm()
            return False

    async def setup_vm(self):
        """Initial VM setup with Conda and snapshot creation"""
        if not self.iso_image:
            raise ValueError("ISO path is required for setup")

        try:
            # Create custom Alpine ISO with overlay
            print("[Setup]: Creating Alpine overlay...")
            overlay = await self.create_alpine_overlay()

            print("[Setup]: Creating custom Alpine ISO...")
            custom_iso = await self.create_custom_alpine_iso(self.iso_image, overlay)
            self.custom_iso_path = custom_iso

            if not os.path.exists(self.qcow2_path):
                print(f"[Setup]: Creating new disk image at {self.qcow2_path}")
                os.makedirs(os.path.dirname(self.qcow2_path), exist_ok=True)
                subprocess.run([
                    "qemu-img", "create",
                    "-f", "qcow2",
                    self.qcow2_path,
                    "20G"
                ], check=True)

            # Start VM with custom ISO
            print("[Setup]: Starting VM with custom ISO...")
            if not await self.start_vm():
                raise RuntimeError("Failed to start VM")

            # Wait for system to boot and stabilize
            print("[Setup]: Waiting for system to initialize...")
            await asyncio.sleep(60)  # Give more time for initial boot

            # Save initial snapshot
            print("[Setup]: Creating initial snapshot...")
            if not await self.save_snapshot(self.DEFAULT_SNAPSHOT):
                raise RuntimeError("Failed to create snapshot")

            print("[Setup]: Stopping VM to verify snapshot...")
            await self.stop_vm()
            await asyncio.sleep(5)  # Wait for cleanup

            # Verify snapshot by loading it
            print("[Setup]: Verifying snapshot by loading it...")
            if not await self.start_vm(load_snapshot=self.DEFAULT_SNAPSHOT):
                raise RuntimeError("Failed to verify snapshot - unable to load it")

            print("[Setup]: Setup completed successfully")
            return True

        except Exception as e:
            print(f"[Setup]: Failed: {e}")
            if self.qemu_process:
                try:
                    stdout, stderr = await self.qemu_process.communicate()
                    print(f"[Setup] QEMU stdout: {stdout.decode()}")
                    print(f"[Setup] QEMU stderr: {stderr.decode()}")
                except Exception as comm_error:
                    print(f"[Setup] Failed to get QEMU output: {comm_error}")
            return False
        finally:
            await self.stop_vm()

    async def run_command(self, command, load_snapshot=True):
        """Run a command in the VM using the saved snapshot"""
        try:
            print(f"[Command]: Starting VM to execute: {command}")
            if not await self.start_vm(load_snapshot or self.DEFAULT_SNAPSHOT):
                return "", "Failed to start VM", 1

            print(f"[Command]: Executing: {command}")
            await asyncio.sleep(20)

            return await self.execute_ssh_command(command)

        except Exception as e:
            print(f"[Command]: Failed: {e}")
            return "", str(e), 1
        finally:
            await self.stop_vm()

    async def stop_vm(self):
        """Stop the QEMU VM"""
        if self.qmp:
            try:
                await self.qmp.execute('quit')
            except Exception as e:
                print(f"[QMP]: Shutdown error: {e}")
            finally:
                await self.qmp.disconnect()

        if self.qemu_process:
            try:
                self.qemu_process.terminate()
                await asyncio.wait_for(self.qemu_process.wait(), timeout=5)
            except asyncio.TimeoutError:
                print("[Process]: Force killing QEMU process...")
                self.qemu_process.kill()
                await self.qemu_process.wait()
            except Exception as e:
                print(f"[Process]: Error during cleanup: {e}")

        self._cleanup_socket()


async def main():
    parser = argparse.ArgumentParser(description="QEMU ARM64 Runner with Conda")
    parser.add_argument("--qemu-system", required=True, help="qemu-system-aarch64 binary path")
    parser.add_argument("--cdrom", help="Path to ISO image")
    parser.add_argument("--drive", required=True, help="Path to QEMU QCOW2 disk image")
    parser.add_argument("--socket", default="./qmp.sock", help="Path for QMP socket")
    parser.add_argument("--ssh-port", type=int, default=10020, help="Port for NIC socket")
    parser.add_argument("--setup", action="store_true", help="Perform initial setup and create snapshot")
    parser.add_argument("--run", help="Command to execute in the VM")
    parser.add_argument("--load-snapshot", default=None, help="Load snapshot from file")

    args = parser.parse_args()

    if not os.path.exists(args.qemu_system):
        raise FileNotFoundError(f"QEMU executable not found at {args.qemu_system}")

    runner = ARM64Runner(
        qemu_system=args.qemu_system,
        iso_image=args.cdrom,
        qcow2_path=args.drive,
        socket_path=args.socket,
        ssh_port=args.ssh_port,
    )

    try:
        if args.setup:
            print("Performing initial setup...")
            await runner.setup_vm()
        elif args.run:
            print(f"Executing command: {args.run}")
            stdout, stderr, returncode = await runner.run_command(
                args.run,
                load_snapshot=args.load_snapshot or ARM64Runner.DEFAULT_SNAPSHOT)
            print("Command output:")
            print(stdout)
            if stderr:
                print("Errors:")
                print(stderr)
            print(f"Return code: {returncode}")
        else:
            print("No action specified. Use --setup/--run")
    finally:
        await runner.stop_vm()


if __name__ == "__main__":
    asyncio.run(main())