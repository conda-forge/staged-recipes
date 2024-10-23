import argparse
import asyncio
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

    def __init__(self, qemu_system, qcow2_path, socket_path, iso_image=None, ssh_port=10022):
        self.qemu_system = qemu_system
        self.iso_image = iso_image
        self.qcow2_path = qcow2_path
        self.socket_path = socket_path
        self.ssh_port = ssh_port
        self.qmp = QMPClient('ARM64 VM')
        self.qemu_process = None

    def _build_qemu_command(self, load_snapshot=None):
        cmd = [
            self.qemu_system,
            "-M", "virt,secure=on",
            "-cpu", "max",
            "-m", "2048",
            "-nographic",
            "-drive", f"file={self.qcow2_path},format=qcow2,if=virtio",
            "-netdev", f"user,id=net1,hostfwd=tcp:127.0.0.1:{self.ssh_port}-:22",
            "-device", "virtio-net-pci,netdev=net1",
            "-qmp", f"unix:{self.socket_path},server,nowait"
        ]

        if self.iso_image:
            cmd.extend(["-cdrom", self.iso_image])

        if platform.machine() == 'arm64':
            cmd.extend(["-accel", "hvf"])

        if load_snapshot:
            cmd.extend(["-loadvm", load_snapshot])

        return cmd

    async def await_boot_sequence(self):
        print("[QMP]: Connecting to VM...")
        await self.qmp.connect(self.socket_path)

        print("[QMP]: Waiting for VM to boot...")
        boot_completed = False
        retry_count = 0
        while not boot_completed and retry_count < 60:
            try:
                status = await self.check_status()
                if status['status'] == 'running':
                    info = await self.qmp.execute('query-name')
                    if info:
                        print(f"[QMP]: VM has finished booting. Name: {info.get('name', 'Unknown')}")
                        boot_completed = True
                        break
            except Exception as e:
                print(f"[QMP]: Error during boot check: {e}")

            retry_count += 1
            await asyncio.sleep(10)

        if not boot_completed:
            raise Exception("VM failed to boot within timeout period")

        print("[QMP]: VM is ready")

    async def check_status(self):
        return await self.qmp.execute('query-status')

    async def execute_ssh_command(self, command, timeout=300):
        """Execute command via SSH and return output"""
        ssh_cmd = [
            "ssh", "-p", str(self.ssh_port),
            "-o", "StrictHostKeyChecking=no",
            "-o", "ConnectTimeout=10",
            "root@localhost",
            command
        ]
        process = await asyncio.create_subprocess_exec(
            *ssh_cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        try:
            stdout, stderr = await asyncio.wait_for(process.communicate(), timeout)
            return stdout.decode(), stderr.decode(), process.returncode
        except asyncio.TimeoutError as e:
            process.kill()
            raise TimeoutError(f"Command timed out after {timeout} seconds") from e

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
            print(f"[Setup]: Executing: {cmd}")
            stdout, stderr, returncode = await self.execute_ssh_command(cmd)
            if returncode != 0:
                print("[Setup]: Error executing command:")
                print(f"stdout: {stdout}")
                print(f"stderr: {stderr}")
                raise Exception(f"Failed to execute: {cmd}")
            print("[Setup]: Command completed successfully")

        # Verify Conda installation
        stdout, stderr, returncode = await self.execute_ssh_command("/root/miniconda/bin/conda --version")
        if returncode == 0:
            print(f"[Setup]: Conda installed successfully: {stdout.strip()}")
        else:
            raise Exception("Failed to verify Conda installation")

    async def setup_vm(self):
        """Initial VM setup with Conda and snapshot creation"""
        if not self.iso_image:
            raise ValueError("ISO path is required for setup")

        cmd = self._build_qemu_command(load_snapshot=False)
        print("[QMP]: Starting VM for setup...")

        self.qemu_process = await asyncio.create_subprocess_exec(
            *cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )

        await self.await_boot_sequence()
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
        stdout, stderr, returncode = await self.execute_ssh_command(command)
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
    parser.add_argument("--socket", default="/tmp/qmp.sock", help="Path for QMP socket")
    parser.add_argument("--setup", action="store_true", help="Perform initial setup and create snapshot")
    parser.add_argument("--run", help="Command to execute in the VM")
    parser.add_argument("--load-snapshot", default=None, help="Load snapshot from file")

    args = parser.parse_args()

    runner = ARM64Runner(
        qemu_system=args.qemu_system,
        iso_image=args.cdrom,
        qcow2_path=args.drive,
        socket_path=args.socket
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