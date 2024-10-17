import asyncio
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

    async def disconnect(self):
        with contextlib.suppress(Exception):
            await self.qmp.disconnect()
        print("QMP connection closed")

    async def check_status(self):
        status = await self.qmp.execute('query-status')
        print(f"VM status: {status['status']}")
        return status['status']

    async def execute_command(self, command):
        response = await self.qmp.execute('guest-exec', command=command)
        if 'pid' in response:
            while True:
                status = await self.qmp.execute('guest-exec-status', pid=response['pid'])
                if status['exited']:
                    return status
                await asyncio.sleep(1)
        return None

    async def install_miniconda(self):
        print("Installing Miniconda...")

        print("Downloading Miniconda installer...")
        await self.execute_command(f"wget {self.MINICONDA_URL} -O /tmp/miniconda.sh")

        print("Making installer executable...")
        await self.execute_command("chmod +x /tmp/miniconda.sh")

        print("Running Miniconda installer...")
        result = await self.execute_command("/tmp/miniconda.sh -b -p /root/miniconda")
        if result and result['exitcode'] == 0:
            print("Miniconda installed successfully")
        else:
            print("Failed to install Miniconda")
            return False

        print("Adding Miniconda to PATH...")
        await self.execute_command("echo 'export PATH=/root/miniconda/bin:$PATH' >> /root/.bashrc")

        print("Activating Conda...")
        await self.execute_command("source /root/.bashrc && conda init")

        print("Miniconda installation and setup complete")
        return True

    async def shutdown_vm(self):
        print("Initiating VM shutdown...")
        await self.qmp.execute('system_powerdown')

        for _ in range(60):  # Wait up to 60 seconds
            await asyncio.sleep(1)
            try:
                status = await self.check_status()
                if status == 'shutdown':
                    print("VM has shut down successfully")
                    return True
            except Exception:
                print("VM has disconnected")
                return True

        print("VM did not shut down in the expected time")
        return False


async def main():
    vm_manager = AlpineVMManager('alpine-vm', 'qmp-sock')

    try:
        await vm_manager.connect()

        status = await vm_manager.check_status()
        if status != 'running':
            print("VM is not running. Cannot proceed with installation.")
            return

        if await vm_manager.install_miniconda():
            await vm_manager.shutdown_vm()

    except Exception as e:
        print(f"An error occurred: {e}")

    finally:
        await vm_manager.disconnect()


asyncio.run(main())