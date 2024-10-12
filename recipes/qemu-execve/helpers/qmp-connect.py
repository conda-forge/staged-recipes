import asyncio
from qemu.qmp import QMPClient

async def main():
    qmp = QMPClient('aarch64-vm')
    await qmp.connect('qmp-sock')

    res = await qmp.execute('query-status')
    print(f"VM status: {res['status']}")

    await asyncio.sleep(600)
    res = await qmp.execute('system_powerdown')
    print(f"VM response: {res}")

    await asyncio.sleep(120)
    res = await qmp.execute('query-status')
    print(f"VM status: {res['status']}")

    await qmp.disconnect()

asyncio.run(main())
