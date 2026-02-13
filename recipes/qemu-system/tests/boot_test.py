#!/usr/bin/env python3
"""Cross-platform QEMU boot test for conda-forge."""
import os
import subprocess
import sys
import time
import urllib.request
from pathlib import Path


def download_file(url: str, dest: str) -> None:
    """Download a file if it doesn't exist."""
    if not Path(dest).exists():
        print(f"Downloading {url}...")
        urllib.request.urlretrieve(url, dest)


def run_boot_test(arch: str, prefix: str) -> bool:
    """Run a QEMU boot test for the specified architecture."""

    # Configuration per architecture
    configs = {
        "aarch64": {
            "kernel_url": "https://download.cirros-cloud.net/0.6.3/cirros-0.6.3-aarch64-kernel",
            "initrd_url": "https://download.cirros-cloud.net/0.6.3/cirros-0.6.3-aarch64-initramfs",
            "kernel": "cirros-kernel",
            "initrd": "cirros-initramfs",
            "qemu_args": [
                "-M", "virt",
                "-cpu", "cortex-a57",
                "-m", "256",
                "-nographic",
                "-netdev", "user,id=net0",
                "-device", "virtio-net-pci,netdev=net0,romfile=",
                "-append", "console=ttyAMA0 ds=nocloud",
            ],
            "success_pattern": "Starting syslogd",
        },
        "ppc64": {
            "kernel_url": "https://download.cirros-cloud.net/0.6.3/cirros-0.6.3-ppc64le-kernel",
            "initrd_url": "https://download.cirros-cloud.net/0.6.3/cirros-0.6.3-ppc64le-initramfs",
            "kernel": "cirros-kernel",
            "initrd": "cirros-initramfs",
            "qemu_args": [
                "-M", "pseries",
                "-cpu", "power9",
                "-m", "512",
                "-nographic",
                "-netdev", "user,id=net0",
                "-device", "virtio-net-pci,netdev=net0,romfile=",
                "-append", "console=hvc0 ds=nocloud",
            ],
            "success_pattern": "Starting syslogd",
        },
        "riscv64": {
            "kernel_url": "https://deb.debian.org/debian/dists/stable/main/installer-riscv64/current/images/netboot/debian-installer/riscv64/linux",
            "initrd_url": "https://deb.debian.org/debian/dists/stable/main/installer-riscv64/current/images/netboot/debian-installer/riscv64/initrd.gz",
            "kernel": "linux",
            "initrd": "initrd.gz",
            "qemu_args": [
                "-M", "virt",
                "-m", "512",
                "-nographic",
                "-netdev", "user,id=net0",
                "-device", "virtio-net-pci,netdev=net0,romfile=",
                "-append", "console=ttyS0 earlycon=sbi",
            ],
            "success_pattern": "Linux version",
            "bios": True,
        },
    }

    if arch not in configs:
        print(f"Unknown architecture: {arch}")
        return False

    config = configs[arch]

    # Download kernel and initrd
    download_file(config["kernel_url"], config["kernel"])
    download_file(config["initrd_url"], config["initrd"])

    # Build QEMU command
    qemu_exe = f"qemu-system-{arch}"
    if sys.platform == "win32":
        qemu_exe += ".exe"

    cmd = [qemu_exe] + config["qemu_args"] + [
        "-kernel", config["kernel"],
        "-initrd", config["initrd"],
    ]

    # Add BIOS for riscv64
    if config.get("bios"):
        if sys.platform == "win32":
            bios_path = Path(prefix) / "Library" / "share" / "qemu" / "opensbi-riscv64-generic-fw_dynamic.bin"
        else:
            bios_path = Path(prefix) / "share" / "qemu" / "opensbi-riscv64-generic-fw_dynamic.bin"
        cmd.extend(["-bios", str(bios_path)])

    print(f"Running: {' '.join(cmd)}")

    # Run QEMU with timeout
    log_file = Path("boot.log")
    timeout_seconds = 60

    try:
        with open(log_file, "w") as log:
            proc = subprocess.Popen(
                cmd,
                stdout=log,
                stderr=subprocess.STDOUT,
                text=True,
            )

            # Wait up to timeout_seconds, checking for success pattern
            start_time = time.time()
            while time.time() - start_time < timeout_seconds:
                time.sleep(5)

                # Check if process ended
                if proc.poll() is not None:
                    break

                # Check log for success pattern
                if log_file.exists():
                    content = log_file.read_text(errors="replace")
                    if config["success_pattern"] in content:
                        print(f"Found success pattern: {config['success_pattern']}")
                        proc.terminate()
                        try:
                            proc.wait(timeout=5)
                        except subprocess.TimeoutExpired:
                            proc.kill()
                        break
            else:
                # Timeout reached
                print(f"Timeout after {timeout_seconds}s, terminating QEMU...")
                proc.terminate()
                try:
                    proc.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    proc.kill()

    except Exception as e:
        print(f"Error running QEMU: {e}")
        return False

    # Check results
    if not log_file.exists():
        print("No boot.log created")
        return False

    content = log_file.read_text(errors="replace")
    print(f"--- Boot log (last 50 lines) ---")
    lines = content.splitlines()
    for line in lines[-50:]:
        print(line)
    print("--- End boot log ---")

    if config["success_pattern"] in content:
        print(f"\n{arch} boot test PASSED")
        return True
    else:
        print(f"\n{arch} boot test FAILED - pattern '{config['success_pattern']}' not found")
        return False


def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <arch> [prefix]")
        print("  arch: aarch64, ppc64, or riscv64")
        sys.exit(1)

    arch = sys.argv[1]
    prefix = sys.argv[2] if len(sys.argv) > 2 else os.environ.get("PREFIX", "/usr/local")

    success = run_boot_test(arch, prefix)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
