import argparse
import asyncio
import contextlib
import os
import platform
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

    def __init__(self, qemu_system, qcow2_path, socket_path, iso_image=None, ssh_port=10022, nic_port=2000):
        self.qemu_system = qemu_system
        self.iso_image = iso_image
        self.qcow2_path = qcow2_path
        self.socket_path = socket_path
        self.nic_port = nic_port
        self.ssh_port = ssh_port
        self.qmp = QMPClient('ARM64 VM')
        self.qemu_process = None
        self.virtio_path = "./vm_console"

    def _build_qemu_command(self, load_snapshot=None):
        if not os.path.exists(self.qemu_system):
            raise FileNotFoundError(f"QEMU executable not found at {self.qemu_system}")

        socket_dir = os.path.dirname(self.socket_path)
        if not os.path.exists(socket_dir):
            os.makedirs(socket_dir, exist_ok=True)
            print(f"[DEBUG]: Created socket directory: {socket_dir}")

        cmd = [
            self.qemu_system,
            "-name", f"QEMU User ({os.path.basename(self.qemu_system)})",
            "-M", "virt,secure=on",
            "-cpu", "max",
            "-m", "2048",
            "-nographic",
            "-drive", f"file={self.qcow2_path},format=qcow2,if=virtio",
            "-qmp", f"unix:{self.socket_path},server,nowait",
            # "-device", "virtio-serial-pci",
            # "-chardev", f"socket,id=console0,path={self.virtio_path},server=on",
            # "-device", "virtserialport,chardev=console0,name=console.0",
            "-net", "user,hostfwd=tcp::10022-:22",
            "-net", "nic",
            # networking for internet access
            # "-netdev", "user,id=net0",
            # "-device", "virtio-net-pci,netdev=net0",
            # "-device", "virtserialport,chardev=console0,name=console0",
        ]

        print(f"[DEBUG]: Socket path: {self.socket_path}")
        print(f"[DEBUG]: Socket directory exists: {os.path.exists(socket_dir)}")
        print(f"[DEBUG]: Socket directory permissions: {oct(os.stat(socket_dir).st_mode)}")

        print(f"[DEBUG]: Socket path: {self.virtio_path}")
        print(f"[DEBUG]: Socket path exists: {os.path.exists(f'{self.virtio_path}')}")

        if self.iso_image:
            cmd.extend(["-cdrom", self.iso_image])

        if platform.machine() == 'arm64':
            cmd.extend(["-accel", "hvf"])
        else:
            cmd.extend(["-accel", "tcg,thread=single"])

        if load_snapshot:
            cmd.extend(["-loadvm", load_snapshot])

        return cmd

    async def _log_output(self, stream, prefix):
        """Log output from a stream with a prefix"""
        while True:
            try:
                line = await stream.readline()
                if not line:
                    break
                print(f"[{prefix}]: {line.decode().rstrip()}")
            except Exception as e:
                print(f"Error reading {prefix} stream: {e}")
                break

    async def _log_console(self):
        """Monitor VM console output"""
        while True:
            try:
                # Try to read console through QMP's human-monitor-command
                response = await self.qmp.execute('human-monitor-command',
                                                {'command-line': 'info chardev'})
                print(f"[Console]: {response}")
            except Exception as e:
                print(f"[Console]: Error reading console: {e}")
            await asyncio.sleep(1)

    async def _monitor_console(self):
        """Monitor VM console output through QMP"""
        while True:
            try:
                commands = [
                    'info status',
                    'info qtree',
                    'info chardev',
                    'system_reset',
                    'sendkey ret',
                ]
                for cmd in commands:
                    response = await self.qmp.execute('human-monitor-command',
                                                      {'command-line': cmd})
                    print(f"[Monitor {cmd}]: {response}")

                # Try reading directly from the chardev
                response = await self.qmp.execute('query-chardev')
                print(f"[Chardev Status]: {response}")

            except Exception as e:
                print(f"[Console Monitor]: {e}")

            await asyncio.sleep(5)

    async def check_status(self):
        return await self.qmp.execute('query-status')

    async def check_qemu_features(self):
        """Check if QEMU has virtio-serial support"""
        cmd = [self.qemu_system, "-device", "help"]
        process = await asyncio.create_subprocess_exec(
            *cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        stdout, stderr = await process.communicate()
        devices = stdout.decode()

        print("[DEBUG] Available QEMU devices:")
        print(devices)

        return "virtserialport" in devices

    async def await_boot_sequence(self):
        """Wait for VM to boot and connect to QMP"""
        # Await creation of QMP socket
        retry_count = 0
        while not os.path.exists(self.socket_path):
            retry_count += 1
            await asyncio.sleep(10)
            if retry_count > 300:
                raise TimeoutError("QMP socket not ready after 300 seconds")

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
                    print(f"[QMP]: VM has finished booting. VM name: {info.get('name', 'Unknown')}")
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

    async def execute_nic_command(self, command):
        """Execute command via network socket instead of SSH"""
        try:
            # Open socket connection to VM
            reader, writer = await asyncio.open_connection(
                'localhost', self.nic_port,
                limit=4096,
            )
            print("[Command]: Connected to socket")

            # Send command
            print(f"[Command]: Sending: {command}")
            writer.write(f"{command}\n".encode())
            await writer.drain()
            print("[Command]: Command sent")

            # Read response
            try:
                response = await asyncio.wait_for(reader.read(4096), timeout=10.0)
                decoded_response = response.decode()
                print(f"[Command]: Received response: {decoded_response}")
            except asyncio.TimeoutError:
                print("[Command]: Timeout waiting for response")
                decoded_response = ""

            writer.close()
            await writer.wait_closed()
            print("[Command]: Connection closed")

            return decoded_response, "", 0
        except ConnectionRefusedError:
            print(f"[Command]: Connection refused on port {self.nic_port}")
            return "", "Connection refused", 1
        except Exception as e:
            print(f"[Command]: Error: {e}")
            return "", str(e), 1

    async def execute_command(self, command):
        """Execute command via virtio-serial port"""
        print(f"[Command]: Connecting to virtio-serial at {self.virtio_path}")
        try:
            # Connect to Unix domain socket created by QEMU for virtio-serial
            reader, writer = await asyncio.open_unix_connection(self.virtio_path)
            print("[Command]: Connected to virtio-serial")

            # Send command with newline
            command_bytes = f"{command}\n".encode()
            print(f"[Command]: Sending ({len(command_bytes)} bytes): {command}")
            writer.write(command_bytes)
            await writer.drain()
            print("[Command]: Command sent, awaiting response")

            # Read response with timeout
            try:
                response = await asyncio.wait_for(reader.read(4096), timeout=30.0)
                decoded = response.decode()
                print(f"[Command]: Received ({len(response)} bytes): {decoded}")
            except asyncio.TimeoutError:
                print("[Command]: Timeout waiting for response")
                decoded = ""

            writer.close()
            await writer.wait_closed()
            print("[Command]: Connection closed")

            return decoded, "", 0

        except FileNotFoundError:
            print(f"[Command]: virtio-serial socket not found at {self.virtio_path}")
            return "", "virtio-serial socket not found", 1
        except Exception as e:
            print(f"[Command]: Error: {type(e).__name__} - {e}")
            return "", str(e), 1

    async def setup_conda(self):
        """Install and configure Conda in the VM"""
        print("[Setup]: Installing Conda...")
        commands = [
            # Update system and install dependencies
            "apk update",
            "apk add wget ca-certificates bash",

            # Download and install Miniconda
            "wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O /tmp/miniconda.sh",
            "chmod +x /tmp/miniconda.sh",
            "/tmp/miniconda.sh -b -p /root/miniconda",

            # Configure Conda
            "echo 'export PATH=/root/miniconda/bin:$PATH' >> /root/.bashrc",
            "source /root/.bashrc",
            "/root/miniconda/bin/conda init"
        ]

        for cmd in commands:
            print(f"[Setup]:    Executing: {cmd}")
            stdout, stderr, returncode = await self.execute_command(cmd)
            if returncode != 0:
                print("[Setup]:     '-> Error executing command:")
                print(f"stdout: {stdout}")
                print(f"stderr: {stderr}")
                raise Exception(f"Failed to execute: {cmd}")
            print("[Setup]:     '-> Command completed successfully")

        # Verify Conda installation
        stdout, stderr, returncode = await self.execute_command("/root/miniconda/bin/conda --version")
        if returncode == 0:
            print(f"[Setup]: Conda installed successfully: {stdout.strip()}")
        else:
            raise Exception("Failed to verify Conda installation")

    async def setup_vm(self):
        """Initial VM setup with Conda and snapshot creation"""
        if not self.iso_image:
            raise ValueError("ISO path is required for setup")

        # if not await self.check_qemu_features():
        #     raise RuntimeError("QEMU does not have virtio-serial support. Need to rebuild with virtio support.")

        cmd = self._build_qemu_command(load_snapshot=False)
        print("Starting VM with command:", ' '.join(cmd))

        self.qemu_process = await asyncio.create_subprocess_exec(
            *cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        stderr_task = asyncio.create_task(self._log_output(self.qemu_process.stderr, "QEMU ERR"))

        try:
            await asyncio.sleep(2)
            print(f"[DEBUG]: Checking if virtio socket was created: {os.path.exists(self.virtio_path)}")

            if self.qemu_process.returncode is not None:
                # If QEMU has already exited, get the stderr
                stderr = await self.qemu_process.stderr.read()
                print(f"[DEBUG]: QEMU exited with code {self.qemu_process.returncode}")
                print(f"[DEBUG]: QEMU stderr: {stderr.decode()}")
                raise RuntimeError("QEMU failed to start")

            await self.await_boot_sequence()
        except Exception as e:
            print(f"Setup failed: {e}")
            # Try to get any remaining stderr
            if self.qemu_process and not self.qemu_process.stderr.at_eof():
                remaining_error = await self.qemu_process.stderr.read()
                print(f"[DEBUG]: Remaining QEMU errors: {remaining_error.decode()}")
            raise
        finally:
            stderr_task.cancel()
            with contextlib.suppress(asyncio.CancelledError):
                await stderr_task
        await self.setup_conda()
        await self.save_snapshot(self.DEFAULT_SNAPSHOT)

    async def run_command(self, command, load_snapshot=True):
        """Run a command in the VM using the saved snapshot"""
        cmd = self._build_qemu_command(load_snapshot=load_snapshot)

        self.qemu_process = await asyncio.create_subprocess_exec(
            *cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )

        await self.await_boot_sequence()
        stdout, stderr, returncode = await self.execute_command(command)
        return stdout, stderr, returncode

    async def stop_vm(self):
        """Stop the QEMU VM"""
        if self.qmp:
            try:
                await self.qmp.execute('quit')
            except Exception as e:
                print(f"[QMP]: Error during shutdown: {e}")
            finally:
                await self.qmp.disconnect()

        if self.qemu_process:
            self.qemu_process.terminate()
            await self.qemu_process.wait()


async def main():
    parser = argparse.ArgumentParser(description="QEMU ARM64 Runner with Conda")
    parser.add_argument("--qemu-system", required=True, help="qemu-system-aarch64 binary path")
    parser.add_argument("--cdrom", required=True, help="Path to ISO image")
    parser.add_argument("--drive", required=True, help="Path to QEMU QCOW2 disk image")
    parser.add_argument("--socket", default="./qmp.sock", help="Path for QMP socket")
    parser.add_argument("--nic-port", type=int, default=2000, help="Port for NIC socket")
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
        nic_port=args.nic_port,
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