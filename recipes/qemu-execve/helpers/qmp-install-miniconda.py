import asyncio
from qemu.qmp import QMPClient

MINICONDA_URL = "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"

async def execute_command(qmp, command):
    response = await qmp.execute('guest-exec', command=command)
    if 'pid' in response:
        while True:
            status = await qmp.execute('guest-exec-status', pid=response['pid'])
            if status['exited']:
                return status
            await asyncio.sleep(1)
    return None

async def main():
    qmp = QMPClient('aarch64-vm')
    await qmp.connect('qmp-sock')

    try:
        # Step 1: Download Miniconda installer
        print("Downloading Miniconda installer...")
        await execute_command(qmp, f"wget {MINICONDA_URL} -O /tmp/miniconda.sh")

        # Step 2: Make the installer executable
        print("Making installer executable...")
        await execute_command(qmp, "chmod +x /tmp/miniconda.sh")

        # Step 3: Install Miniconda
        print("Installing Miniconda...")
        install_command = "/tmp/miniconda.sh -b -p /root/miniconda"
        result = await execute_command(qmp, install_command)
        if result and result['exitcode'] == 0:
            print("Miniconda installed successfully")
        else:
            print("Failed to install Miniconda")
            return

        # Step 4: Add Miniconda to PATH
        print("Adding Miniconda to PATH...")
        await execute_command(qmp, "echo 'export PATH=/root/miniconda/bin:$PATH' >> /root/.bashrc")

        # Step 5: Activate Conda
        print("Activating Conda...")
        await execute_command(qmp, "source /root/.bashrc && conda init")

        print("Miniconda installation and setup complete")

    except Exception as e:
        print(f"An error occurred: {e}")

    finally:
        await qmp.disconnect()

asyncio.run(main())