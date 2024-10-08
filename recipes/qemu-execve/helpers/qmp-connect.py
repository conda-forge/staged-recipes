import asyncio
from qemu.qmp import QMPClient

async def main():
    qmp = QMPClient('aarch64-vm')
    await qmp.connect('qmp.sock')

    res = await qmp.execute('query-status')
    print(f"VM status: {res['status']}")

    qmp.execute('system_powerdown')
    await qmp.disconnect()

asyncio.run(main())
