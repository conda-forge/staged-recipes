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

    def _build_qemu_command(self, startup_script=None):
        cmd = [
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
            "-drive", f"file={startup_script},format=raw",
            "-qmp", f"unix:{self.socket_path},server,nowait",
            "-serial", "stdio",
            "-append", "console=ttyAMA0 root=/dev/vda rw init=/bin/sh"
        ]
        if startup_script:
            cmd.extend([
                "-drive", f"file={startup_script},format=raw",
                "-append", "console=ttyAMA0 root=/dev/vda rw init=/bin/sh"
            ])
        return cmd

    def _create_startup_script(self):
        script_content = """#!/bin/sh
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O /tmp/miniconda.sh
chmod +x /tmp/miniconda.sh
/tmp/miniconda.sh -b -p /root/miniconda
echo 'export PATH=/root/miniconda/bin:$PATH' >> /root/.bashrc
source /root/.bashrc
conda init
echo "Miniconda installation complete" > /tmp/miniconda_installed
poweroff
"""
        with tempfile.NamedTemporaryFile(mode='w+', delete=False, suffix='.sh') as temp:
            temp.write(script_content)
            return temp.name

    def _create_verification_script(self):
        script_content = """#!/bin/sh
source /root/.bashrc
conda --version
echo "Verification complete"
poweroff
"""
        with tempfile.NamedTemporaryFile(mode='w+', delete=False, suffix='.sh') as temp:
            temp.write(script_content)
            return temp.name

    async def _run_vm(self, cmd, expected_output):
        process = await asyncio.create_subprocess_exec(
            *cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )

        while True:
            line = await process.stdout.readline()
            if not line:
                break
            decoded_line = line.decode().strip()
            print(decoded_line)
            if expected_output in decoded_line:
                return True

        await process.wait()
        return False

    async def setup_and_run(self):
        startup_script = self._create_startup_script()
        cmd = self._build_qemu_command(startup_script)

        try:
            print("Starting VM for initial setup...")
            success = await self._run_vm(cmd, "Miniconda installation complete")
            if not success:
                print("Failed to install Miniconda.")
                return False
        finally:
            os.unlink(startup_script)

        return True

    async def verify_installation(self):
        verification_script = self._create_verification_script()
        cmd = self._build_qemu_command(verification_script)

        try:
            print("Starting VM for verification...")
            success = await self._run_vm(cmd, "conda")
            if success:
                print("Miniconda installation verified successfully.")
            else:
                print("Failed to verify Miniconda installation.")
            return success
        finally:
            os.unlink(verification_script)

    async def start_normal(self):
        cmd = self._build_qemu_command()
        print("Starting VM normally...")
        self.qemu_process = await asyncio.create_subprocess_exec(*cmd)
        await self.qemu_process.wait()

    async def stop_vm(self):
        if self.qemu_process:
            await self.qmp.execute('quit')
            self.qemu_process.wait()
        await self.qmp.disconnect()


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
        print("Setting up VM...")
        if await emulator.setup_and_run():
            if await emulator.verify_installation():
                await emulator.start_normal()
            else:
                print("Miniconda installation could not be verified. Please check the VM setup.")
        else:
            print("Initial setup failed. Miniconda may not have been installed correctly.")
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