import asyncio
from qemu.qmp import QMPClient

async def main():
    qmp = QMPClient('aarch64-vm')
    await qmp.connect('qmp-sock')

    await qmp.execute('system_powerdown')
    print("VM is shutting down...")
    await asyncio.sleep(60)

    try:
        await qmp.connect('qmp-sock')
        print("Warning: VM is still running after shutdown commands")
    except Exception as e:
        print("VM has successfully shut down")

    try:
        await qmp.disconnect()
    except:
        pass

asyncio.run(main())
