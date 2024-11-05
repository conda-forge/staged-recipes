import argparse
import asyncio
import contextlib
import os
import platform
import shutil
import subprocess
from typing import Protocol

from qemu.qmp import QMPClient


class QMPProtocol(Protocol):
    qmp: QMPClient


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

    def __init__(self, qemu_system, qcow2_path, socket_path, iso_image=None, ssh_port=10022):
        self.qemu_system = qemu_system
        self.iso_image = iso_image
        self.qcow2_path = qcow2_path
        self.socket_path = socket_path
        self.ssh_port = ssh_port
        self.qmp = QMPClient('ARM64 VM')
        self.qemu_process = None
        self.virtio_path = "./vm_console"

    def _build_qemu_command(self, load_snapshot=None):
        if not os.path.exists(self.qemu_system):
            raise FileNotFoundError(f"QEMU executable not found at {self.qemu_system}")

        socket_dir = os.path.dirname(self.socket_path)
        os.makedirs(socket_dir, exist_ok=True)

        cmd = [
            self.qemu_system,
            "-name", f"QEMU User ({os.path.basename(self.qemu_system)})",
            "-M", "virt",
            "-cpu", "max",
            "-m", 2048,
            "-nographic",
            "-drive", f"file={self.qcow2_path},format=qcow2",
            "-qmp", f"unix:{self.socket_path},server,nowait",
            "-netdev", f"user,id=net0,hostfwd=tcp::{self.ssh_port}-:22",
            "-device", "virtio-net-pci,netdev=net0",
        ]

        # Add UEFI firmware if available
        edk2_code = os.path.join(os.path.dirname(self.qemu_system), "../share/qemu/edk2-aarch64-code.fd")
        edk2_vars = os.path.join(os.path.dirname(self.qemu_system), "../share/qemu/edk2-aarch64-vars.fd")

        if os.path.exists(edk2_code) and os.path.exists(edk2_vars):
            cmd.extend([
                "-drive", f"if=pflash,format=raw,file={edk2_code},readonly=on",
                "-drive", f"if=pflash,format=raw,file={edk2_vars}"
            ])

        if self.iso_image:
            cmd.extend(["-cdrom", self.iso_image])

        if platform.machine() == 'arm64':
            cmd.extend(["-accel", "hvf"])
        else:
            cmd.extend(["-accel", "tcg,thread=single"])

        if load_snapshot:
            cmd.extend(["-loadvm", load_snapshot])

        return cmd

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

    async def create_custom_alpine_iso(self, original_iso, overlay_file):
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

        # Try multiple connection tests with delays
        for i in range(3):
            keygen = [
                "ssh-keygen",
                "-t", "rsa",
                "-N", "",  # No passphrase
                "-f", "/Users/runner/.ssh/id_rsa"
            ]

            keyscan = [
                "ssh-keyscan",
                "-v",
                "-H", "localhost",
                "-p", "10022",
                "-T", "60"
            ]

            print(f"\n[DEBUG] Connection test {i + 1}:")
            try:
                # Test with netcat
                process = await asyncio.create_subprocess_exec(
                    "nc", "-zv", "localhost", "10022",
                    stdout=asyncio.subprocess.PIPE,
                    stderr=asyncio.subprocess.PIPE
                )
                stdout, stderr = await process.communicate()
                print(f"[DEBUG] Netcat output: {stdout.decode()}{stderr.decode()}")

                await asyncio.sleep(2)  # Wait between tests

                # Test with ssh connection only (no command)
                process = await asyncio.create_subprocess_exec(
                    "ssh", "-v", "-p", "10022",
                    "-o", "ConnectTimeout=60",
                    "-o", "StrictHostKeyChecking=no",
                    "conda_build@localhost",
                    "exit",
                    stdout=asyncio.subprocess.PIPE,
                    stderr=asyncio.subprocess.PIPE
                )
                stdout, stderr = await process.communicate()
                print(f"[DEBUG] SSH test output: {stdout.decode()}{stderr.decode()}")

            except Exception as e:
                print(f"[DEBUG] Test {i + 1} error: {e}")

            await asyncio.sleep(2)

        ssh_cmd = [
            "ssh",
            "-v",
            "-p", "10022",
            "-i", "/Users/runner/.ssh/id_rsa",
            "-o", "StrictHostKeyChecking=accept-new",
            "-o", "UserKnownHostsFile=/dev/null",
            "conda_build@localhost",
            command
        ]

        netcat = [
            "nc",
            "-zv",  # Verbose scan
            "localhost",
            "10022"
        ]

        print(f"[Command]: Executing via SSH: {command}")
        try:
            print("[DEBUG] Testing port with netcat...")
            process = await asyncio.create_subprocess_exec(
                *netcat,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            stdout, stderr = await process.communicate()
            print(f"[DEBUG] Netcat result: {stdout.decode()}\n{stderr.decode()}")

            process = await asyncio.create_subprocess_exec(
                *keygen,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            stdout, stderr = await process.communicate()
            print(f"[Command]: SSH Keygen stdout: {stdout.decode()}")
            process = await asyncio.create_subprocess_exec(
                *keyscan,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            stdout, stderr = await process.communicate()
            print(f"[Command]: SSH Keyscan stdout: {stdout.decode()}")
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

    async def setup_vm(self):
        """Initial VM setup with Conda and snapshot creation"""
        if not self.iso_image:
            raise ValueError("ISO path is required for setup")

        overlay = await self.create_alpine_overlay()
        custom_iso = await self.create_custom_alpine_iso(self.iso_image, overlay)

        self.iso_image = custom_iso
        cmd = self._build_qemu_command(load_snapshot=False)
        print("Starting VM with command:", ' '.join(cmd))

        self.qemu_process = await asyncio.create_subprocess_exec(
            *cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )

        try:
            await self.await_boot_sequence()
            await self.save_snapshot(self.DEFAULT_SNAPSHOT)
        except Exception as e:
            print(f"Setup failed: {e}")
            if self.qemu_process:
                try:
                    stdout, stderr = await self.qemu_process.communicate()
                    print(f"QEMU stdout: {stdout.decode()}")
                    print(f"QEMU stderr: {stderr.decode()}")
                except Exception:
                    pass
            raise

    async def run_command(self, command, load_snapshot=True):
        """Run a command in the VM using the saved snapshot"""
        try:
            cmd = self._build_qemu_command(load_snapshot=load_snapshot)
            print(f"Starting VM for command: {command}")

            self.qemu_process = await asyncio.create_subprocess_exec(
                *cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )

            await self.await_boot_sequence()
            # Wait for system to be ready
            await asyncio.sleep(10)

            stdout, stderr, returncode = await self.execute_ssh_command(command)
            return stdout, stderr, returncode
        finally:
            await self.stop_vm()

    async def stop_vm(self):
        """Stop the QEMU VM"""
        if self.qmp and self.qmp.is_connected():
            try:
                await self.qmp.execute('quit')
            except Exception as e:
                print(f"[QMP]: Error during shutdown: {e}")
            finally:
                await self.qmp.disconnect()

        if self.qemu_process:
            try:
                self.qemu_process.terminate()
                await asyncio.wait_for(self.qemu_process.wait(), timeout=5)
            except asyncio.TimeoutError:
                self.qemu_process.kill()
                await self.qemu_process.wait()
        # Clean up socket file
        if os.path.exists(self.socket_path):
            os.unlink(self.socket_path)

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