import asyncio
from qemu.qmp import QMPClient

async def main():
    qmp = QMPClient('aarch64-vm')
    await qmp.connect('qmp-sock')

    await qmp.execute('human-monitor-command', command_line='logfile boot_log.txt')
    await qmp.execute('human-monitor-command', command_line='log guest_errors')

    while True:
        status = await qmp.execute('query-status')
        if status['status'] == 'running':
            # Check if the boot process is complete
            with open('boot_log.txt', 'r') as f:
                log = f.read()
                if 'login:' in log:
                    print("VM has finished booting")
                    break
        await asyncio.sleep(10)

    res = await qmp.execute('system_powerdown')
    print(f"VM response: {res}")

    res = await qmp.execute('quit')
    print(f"VM response: {res}")

    await asyncio.sleep(120)
    res = await qmp.execute('query-status')
    print(f"VM status: {res['status']}")

    await qmp.disconnect()

asyncio.run(main())
