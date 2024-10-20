import asyncio
import base64
import contextlib
import fcntl
import os
import pty
import select
import socket
import subprocess
import argparse
import re
import tempfile

from qemu.qmp import QMPClient

class QEMUUserEmulator:
    MINICONDA_URL = "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"

    def __init__(self, qemu_system,  vm_name, socket_path, ro_edk2, rw_edk2, image, user_image, image_format='qcow2', memory='2048'):
        self.qmp = QMPClient(vm_name)
        self.socket_path = socket_path
        self.qemu_system = qemu_system
        self.ro_edk2 = ro_edk2
        self.rw_edk2 = rw_edk2
        self.image = image
        self.user_image = user_image
        self.image_format = image_format
        self.memory = memory
        self.qemu_process = None
        self.console_master, self.console_slave = pty.openpty()
        self.console_path = os.ttyname(self.console_slave)
        self.console_output = ""
        self.vsock_cid = 3  # CID for the host
        self.vsock_port = 1234  # Arbitrary port number

    def _build_qemu_command(self):
        return [
            self.qemu_system,
            "-name", f"QEMU User ({os.path.basename(self.qemu_system)})",
            "-M", "virt",
            "-accel", "tcg,thread=single",
            "-cpu", "cortex-a57",
            "-m", self.memory,
            "-nographic",
            "-drive", f"if=pflash,format=raw,file={self.ro_edk2},readonly=on",
            "-drive", f"if=pflash,format=raw,file={self.rw_edk2}",
            "-drive", f"file={self.image},format=raw,readonly=on",
            "-drive", f"file={self.user_image},format={self.image_format}",
            "-qmp", f"unix:{self.socket_path},server,nowait",
            "-device", "vhost-vsock-pci,id=vhost-vsock-pci0,guest-cid=5",
            "-serial", "stdio",
        ]

    async def _read_console_output_stdio(self):
        flags = fcntl.fcntl(self.console_master, fcntl.F_GETFL)
        fcntl.fcntl(self.console_master, fcntl.F_SETFL, flags | os.O_NONBLOCK)

        while True:
            await asyncio.sleep(0.1)
            r, _, _ = select.select([self.console_master], [], [], 0)
            if r:
                try:
                    data = os.read(self.console_master, 1024)
                    if data:
                        decoded_data = data.decode('utf-8', errors='replace')
                        print(decoded_data, end='', flush=True)
                        self.console_output += decoded_data
                    else:
                        break
                except OSError:
                    break

    async def _read_console_output(self):
        while True:
            try:
                with socket.socket(socket.AF_VSOCK, socket.SOCK_STREAM) as sock:
                    sock.connect((self.vsock_cid, self.vsock_port))
                    while True:
                        data = sock.recv(1024)
                        if not data:
                            break
                        decoded_data = data.decode('utf-8', errors='replace')
                        print(decoded_data, end='', flush=True)
                        self.console_output += decoded_data
            except Exception as e:
                print(f"Error reading console output: {e}")
                await asyncio.sleep(1)  # Wait before retrying

    async def start_vm(self):
        cmd = self._build_qemu_command()
        self.qemu_process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        await asyncio.sleep(2)
        await self.connect()
        asyncio.create_task(self._read_console_output())

    async def connect(self):
        print("Connecting to VM...")
        await self.qmp.connect(self.socket_path)

        print("Waiting for VM to boot...")
        boot_completed = False
        while not boot_completed:
            try:
                status = await self.check_status()
                if status['status'] == 'running':
                    info = await self.qmp.execute('query-name')
                    if info:
                        print(f"VM has finished booting. VM name: {info.get('name', 'Unknown')}")
                        boot_completed = True
                else:
                    print(f"VM status: {status['status']}")
            except Exception as e:
                print(f"Error querying VM: {e}")

            if not boot_completed:
                await asyncio.sleep(10)
        print("VM is ready. Commands:")
        print(await self.qmp.execute('query-commands'))

    async def stop_vm(self):
        if self.qemu_process:
            await self.qmp.execute('quit')
            self.qemu_process.wait()
        await self.qmp.disconnect()
        os.close(self.console_master)
        os.close(self.console_slave)

    async def check_status(self):
        status = await self.qmp.execute('query-status')
        print(f"VM status: {status['status']}")
        return status

    async def check_file_exists(self, file_path):
        result = await self.execute_command(f"test -f {file_path} && echo 'File exists' || echo 'File does not exist'", expected_output="File exists")
        return result

    async def capture_command_output(self, command):
        self.console_output = ""
        await self.execute_command(command)
        return self.console_output.strip()

    async def execute_command(self, command):
        # Create a temporary script file
        with tempfile.NamedTemporaryFile(mode='w+', delete=False, suffix='.sh') as temp:
            temp.write(f"#!/bin/sh\n{command}\n")
            temp_path = temp.name

        try:
            # Copy the script to the guest
            await self.qmp.execute('guest-file-open', path='/tmp/command.sh', mode='w')
            with open(temp_path, 'rb') as f:
                content = f.read()
                await self.qmp.execute('guest-file-write', handle=0, buf_b64=base64.b64encode(content).decode())
            await self.qmp.execute('guest-file-close', handle=0)

            # Make the script executable and run it
            await self.qmp.execute('guest-exec', path='/bin/chmod', arg=['755', '/tmp/command.sh'])
            response = await self.qmp.execute('guest-exec', path='/tmp/command.sh')

            # Wait for the command to complete
            while True:
                status = await self.qmp.execute('guest-exec-status', pid=response['pid'])
                if status['exited']:
                    break
                await asyncio.sleep(1)

            # Retrieve the command output
            if 'out-data' in status:
                output = base64.b64decode(status['out-data']).decode('utf-8')
                print(f"Command output:\n{output}")

            return status['exitcode'] == 0

        finally:
            # Clean up the temporary file
            os.unlink(temp_path)

    async def execute_command_sock(self, command, expected_output=None, timeout=30):
        print(f"Sending command: {command}")
        try:
            with socket.socket(socket.AF_VSOCK, socket.SOCK_STREAM) as sock:
                sock.connect((self.vsock_cid, self.vsock_port))
                sock.sendall(f"{command}\n".encode('utf-8'))

                start_time = asyncio.get_event_loop().time()
                while (asyncio.get_event_loop().time() - start_time) < timeout:
                    if expected_output and expected_output in self.console_output:
                        print("Command executed successfully. Expected output found.")
                        return True
                    await asyncio.sleep(0.1)

                print("Command execution timed out or expected output not found.")
                return False
        except Exception as e:
            print(f"Error executing command: {e}")
            return False

    async def execute_command_stdio(self, command, expected_output=None, timeout=30):
        async def send_key(key):
            await self.qmp.execute('human-monitor-command', {'command-line': f'sendkey {key}'})
            await asyncio.sleep(0.1)  # Small delay between keystrokes

        print(f"Sending command: {command}")

        await send_key('ret')
        for char in command:
            if char == ' ':
                await send_key('spc')
            elif char in '-=/.:':
                await send_key(char)
            elif char.isupper():
                await send_key(f'shift-{char.lower()}')
            else:
                await send_key(char)
        await send_key('ret')

        start_time = asyncio.get_event_loop().time()
        while (asyncio.get_event_loop().time() - start_time) < timeout:
            await asyncio.sleep(1)
            if expected_output and re.search(expected_output, self.console_output):
                print(self.console_output)
                print("Command executed successfully. Expected output found.")
                return True

        print("Command execution timed out or expected output not found.")
        return False

    async def install_package(self, package_name, install_command, version_command):
        print(f"Installing {package_name}...")
        try:
            success = await self.execute_command(install_command, expected_output="installation finished|100%", timeout=300)
            if not success:
                raise Exception(f"Failed to install {package_name}")

            print(f"Verifying {package_name} installation...")
            version_output = await self.capture_command_output(version_command)
            if package_name.lower() not in version_output.lower():
                print(f"Output: {version_output}")
                raise Exception(f"{package_name} installation verification failed")

            print(f"{package_name} installation complete. Version: {version_output}")
            return True
        except Exception as e:
            print(f"Error during {package_name} installation: {e}")
            return False

    async def install_miniconda_stdio(self):
        miniconda_install_command = (
            f"wget {self.MINICONDA_URL} -O /tmp/miniconda.sh && "
            "chmod +x /tmp/miniconda.sh && "
            "/tmp/miniconda.sh -b -p /root/miniconda && "
            "echo 'export PATH=/root/miniconda/bin:$PATH' >> /root/.bashrc && "
            "source /root/.bashrc && conda init"
        )
        return await self.install_package("Miniconda", miniconda_install_command, "conda --version")

    async def install_miniconda(self):
        print("Installing Miniconda...")
        miniconda_script = """
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O /tmp/miniconda.sh
        chmod +x /tmp/miniconda.sh
        /tmp/miniconda.sh -b -p /root/miniconda
        echo 'export PATH=/root/miniconda/bin:$PATH' >> /root/.bashrc
        source /root/.bashrc
        conda init
        """
        success = await self.execute_command(miniconda_script)
        if success:
            print("Miniconda installed successfully")
        else:
            print("Failed to install Miniconda")
        return success

    async def shutdown_vm(self):
        print("Initiating VM shutdown...")
        await self.qmp.execute('system_powerdown')

        for _ in range(60):  # Wait up to 60 seconds
            await asyncio.sleep(1)
            try:
                status = await self.check_status()
                if status['status'] == 'shutdown':
                    print("VM has shut down successfully")
                    return True
            except Exception:
                print("VM has disconnected")
                return True

        print("VM did not shut down in the expected time")
        return False

async def main(args):
    emulator = QEMUUserEmulator(
        qemu_system=args.qemu_system,
        vm_name=args.vm_name,
        socket_path=args.socket_path,
        ro_edk2=args.ro_edk2,
        rw_edk2=args.rw_edk2,
        image=args.image,
        user_image=args.user_image,
        image_format=args.image_format,
        memory=args.memory
    )

    try:
        print("Starting VM...")
        await emulator.start_vm()

        if args.install_miniconda:
            await emulator.install_miniconda()

        if args.command:
            print(f"Executing command: {args.command}")
            await emulator.execute_command(args.command)

        if args.runtime > 0:
            print(f"Keeping VM running for {args.runtime} seconds...")
            await asyncio.sleep(args.runtime)

    finally:
        print("Stopping VM...")
        await emulator.stop_vm()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="QEMU User Emulator")
    parser.add_argument("--qemu-system", default="qemu-system-aarch64", help="QEMU system")
    parser.add_argument("--vm-name", default="aarch64-vm", help="Name of the VM")
    parser.add_argument("--socket-path", default="qmp-sock", help="Path for the QMP socket")
    parser.add_argument("--ro-edk2", required=True, help="Path to read-only EDK2 firmware")
    parser.add_argument("--rw-edk2", required=True, help="Path to read-write EDK2 firmware")
    parser.add_argument("--image", required=True, help="Path to the disk image")
    parser.add_argument("--user-image", required=True, help="Path to the user image")
    parser.add_argument("--image-format", default="qcow2", help="Format of the disk image")
    parser.add_argument("--memory", default="2048", help="Amount of memory for the VM")
    parser.add_argument("--install-miniconda", action="store_true", help="Install Miniconda in the VM")
    parser.add_argument("--command", help="Command to execute in the VM")
    parser.add_argument("--runtime", type=int, default=0, help="How long to keep the VM running (in seconds)")

    args = parser.parse_args()
    asyncio.run(main(args))