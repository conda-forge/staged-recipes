import asyncio
import base64
import contextlib
from qemu.qmp import QMPClient


class AlpineVMManager:
    MINICONDA_URL = "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"

    def __init__(self, vm_name, socket_path):
        self.qmp = QMPClient(vm_name)
        self.socket_path = socket_path

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

    async def disconnect(self):
        with contextlib.suppress(Exception):
            await self.qmp.disconnect()
        print("QMP connection closed")

    async def check_status(self):
        status = await self.qmp.execute('query-status')
        print(f"VM status: {status['status']}")
        return status

    async def send_key(self, key):
        await self.qmp.execute('human-monitor-command', {'command-line': f'sendkey {key}'})
        await asyncio.sleep(0.1)  # Small delay between keystrokes

    async def execute_command(self, command):
        print(f"Sending command: {command}")

        # Send 'Enter' key to ensure we're at the start of a new line
        await self.send_key('ret')

        # Send each character of the command
        for char in command:
            if char == ' ':
                await self.send_key('spc')
            elif char == '-':
                await self.send_key('minus')
            elif char == '=':
                await self.send_key('equal')
            elif char == '/':
                await self.send_key('slash')
            elif char == '.':
                await self.send_key('dot')
            elif char == ':':
                await self.send_key('shift-semicolon')
            elif char.isupper():
                await self.send_key(f'shift-{char.lower()}')
            else:
                await self.send_key(char)

        # Send 'Enter' key to execute the command
        await self.send_key('ret')

        # Wait for command to complete
        await asyncio.sleep(2)

    async def install_miniconda(self):
        print("Installing Miniconda...")
        try:
            print("Downloading Miniconda installer...")
            result = await self.execute_command(
                "wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O /tmp/miniconda.sh")
            print(f"Download result: {result}")

            print("Making installer executable...")
            result = await self.execute_command("chmod +x /tmp/miniconda.sh")
            print(f"Chmod result: {result}")

            print("Running Miniconda installer...")
            result = await self.execute_command("/tmp/miniconda.sh -b -p /root/miniconda")
            print(f"Installation result: {result}")

            print("Adding Miniconda to PATH...")
            result = await self.execute_command("echo 'export PATH=/root/miniconda/bin:$PATH' >> /root/.bashrc")
            print(f"PATH update result: {result}")

            print("Activating Conda...")
            result = await self.execute_command("source /root/.bashrc && conda init")
            print(f"Conda init result: {result}")

            print("Miniconda installation complete")
        except Exception as e:
            print(f"Error during Miniconda installation: {e}")

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


async def main():
    vm_manager = AlpineVMManager('aarch64-vm', 'qmp-sock')

    try:
        await vm_manager.connect()

        status = await vm_manager.check_status()
        if status['status'] != 'running':
            print("VM is not running. Cannot proceed with installation.")
            return

        if await vm_manager.install_miniconda():
            await vm_manager.shutdown_vm()

    except Exception as e:
        print(f"An error occurred: {e}")

    finally:
        await vm_manager.disconnect()


asyncio.run(main())