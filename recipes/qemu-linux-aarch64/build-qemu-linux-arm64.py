#!/usr/bin/env python3
"""Build script for qemu-linux-aarch64 package (Alpine direct-boot wrapper).

Creates Alpine Linux direct-boot setup for ARM64 emulation.
Supports: osx-64 (Intel Macs), win-64 (Windows)
"""
import os
import shutil
import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path

# Environment
PREFIX = Path(os.environ["PREFIX"])
SRC_DIR = Path(os.environ["SRC_DIR"])
ALPINE_VERSION = os.environ["ALPINE_VERSION"]

# Platform detection
IS_WINDOWS = sys.platform == "win32" or os.environ.get("MSYSTEM")

if IS_WINDOWS:
    SHARE_DIR = PREFIX / "Library" / "share" / "qemu-linux-aarch64"
    BIN_DIR = PREFIX / "Library" / "bin"
else:
    SHARE_DIR = PREFIX / "share" / "qemu-linux-aarch64"
    BIN_DIR = PREFIX / "bin"

print(f"=== Building qemu-linux-aarch64 (direct kernel boot) ===")
print(f"Platform: {'Windows' if IS_WINDOWS else 'Unix'}")

SHARE_DIR.mkdir(parents=True, exist_ok=True)
BIN_DIR.mkdir(parents=True, exist_ok=True)

# Extract netboot files
print("Extracting Alpine netboot...")
netboot_tar = SRC_DIR / "alpine_netboot" / f"alpine-netboot-{ALPINE_VERSION}-aarch64.tar.gz"
with tarfile.open(netboot_tar, "r:gz") as tar:
    tar.extractall(SHARE_DIR)

# Move kernel
kernel_src = SHARE_DIR / "boot" / "vmlinuz-virt"
kernel_dst = SHARE_DIR / "vmlinuz-virt"
shutil.move(str(kernel_src), str(kernel_dst))

# Create initramfs from minirootfs
print("Creating base initramfs from minirootfs...")
with tempfile.TemporaryDirectory() as initramfs_dir:
    initramfs_path = Path(initramfs_dir)

    # Extract minirootfs
    rootfs_tar = SRC_DIR / "alpine_rootfs" / f"alpine-minirootfs-{ALPINE_VERSION}-aarch64.tar.gz"
    with tarfile.open(rootfs_tar, "r:gz") as tar:
        tar.extractall(initramfs_path)

    # Create init script
    init_script = initramfs_path / "init"
    init_script.write_text(r'''#!/bin/sh
# qemu-linux-aarch64 init script - runs target binary and exits

mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t devtmpfs dev /dev

mkdir -p /mnt/share
mount -t 9p -o trans=virtio,version=9p2000.L share /mnt/share 2>/dev/null || {
    echo "ERROR: Failed to mount 9p share" >&2
    poweroff -f
}

if [ ! -f /mnt/share/binary ]; then
    echo "ERROR: No binary found at /mnt/share/binary" >&2
    poweroff -f
fi

ARGS=""
if [ -f /mnt/share/args ]; then
    ARGS=$(cat /mnt/share/args)
fi

chmod +x /mnt/share/binary
cd /mnt/share
./binary $ARGS
EXIT_CODE=$?

echo $EXIT_CODE > /mnt/share/exit_code
sync
poweroff -f
''', encoding="utf-8", newline="\n")
    init_script.chmod(0o755)

    # Create cpio archive using system cpio (available via m2-cpio on Windows)
    print("Creating initramfs archive...")
    initramfs_out = SHARE_DIR / "initramfs-base.cpio.gz"

    # Use shell pipeline: find | cpio | gzip
    find_cmd = "find . -print0" if not IS_WINDOWS else "find ."
    cpio_cmd = "cpio -o -H newc --null" if not IS_WINDOWS else "cpio -o -H newc"

    if IS_WINDOWS:
        # On Windows, use bash to run the pipeline
        bash = shutil.which("bash") or str(PREFIX / "Library" / "usr" / "bin" / "bash.exe")
        cmd = f'cd "{initramfs_path}" && find . | cpio -o -H newc 2>/dev/null | gzip -9 > "{initramfs_out}"'
        subprocess.run([bash, "-c", cmd], check=True)
    else:
        # On Unix, use shell directly
        cmd = f'cd "{initramfs_path}" && find . | cpio -o -H newc 2>/dev/null | gzip -9 > "{initramfs_out}"'
        subprocess.run(cmd, shell=True, check=True)

# Clean up extracted files we don't need
for d in ["boot", "apks"]:
    p = SHARE_DIR / d
    if p.exists():
        shutil.rmtree(p)

# Create the wrapper script
WRAPPER_SCRIPT = r'''#!/bin/bash
# qemu-linux-aarch64: Run ARM64 Linux binaries via QEMU direct boot
set -euo pipefail

if [[ "${OSTYPE:-}" == "msys" ]] || [[ "${OSTYPE:-}" == "cygwin" ]] || [[ -n "${MSYSTEM:-}" ]]; then
    SHARE_DIR="${CONDA_PREFIX}/Library/share/qemu-linux-aarch64"
else
    SHARE_DIR="${CONDA_PREFIX}/share/qemu-linux-aarch64"
fi
KERNEL="${SHARE_DIR}/vmlinuz-virt"
INITRAMFS_BASE="${SHARE_DIR}/initramfs-base.cpio.gz"

usage() {
    cat <<'EOF'
Usage: qemu-linux-aarch64 [options] program [args...]

Run ARM64 Linux binaries using QEMU system emulation with Alpine Linux.

Options:
  --version    Show version information
  --help       Show this help message

Environment:
  QEMU_ARM64_MEMORY   VM memory in MB (default: 256)
  QEMU_ARM64_DEBUG    Show QEMU output if set
EOF
}

version() {
    echo "qemu-linux-aarch64 (Alpine direct-boot wrapper)"
    qemu-system-aarch64 --version | head -1
}

if [[ $# -eq 0 ]]; then
    usage
    exit 1
fi

case "${1:-}" in
    --version) version; exit 0 ;;
    --help|-h) usage; exit 0 ;;
esac

BINARY="$1"
shift

[[ "${BINARY}" = /* ]] || BINARY="$(pwd)/${BINARY}"

if [[ ! -f "${BINARY}" ]]; then
    echo "Error: Binary not found: ${BINARY}" >&2
    exit 127
fi

MEMORY="${QEMU_ARM64_MEMORY:-256}"
DEBUG="${QEMU_ARM64_DEBUG:-}"

TEMP_SHARE=$(mktemp -d -t qemu-linux-aarch64.XXXXXX)
cleanup() { rm -rf "${TEMP_SHARE}"; }
trap cleanup EXIT

cp "${BINARY}" "${TEMP_SHARE}/binary"
chmod +x "${TEMP_SHARE}/binary"

[[ $# -gt 0 ]] && printf '%s\n' "$*" > "${TEMP_SHARE}/args"

QEMU_ARGS=(
    -M virt -cpu cortex-a57 -m "${MEMORY}"
    -kernel "${KERNEL}" -initrd "${INITRAMFS_BASE}"
    -append "console=ttyAMA0 quiet panic=-1"
    -netdev user,id=net0 -device virtio-net-pci,netdev=net0,romfile=
    -virtfs "local,path=${TEMP_SHARE},mount_tag=share,security_model=mapped-xattr,id=share"
    -nographic -no-reboot
)

if [[ -n "${DEBUG}" ]]; then
    qemu-system-aarch64 "${QEMU_ARGS[@]}"
else
    qemu-system-aarch64 "${QEMU_ARGS[@]}" 2>&1 | grep -v '^\[' | grep -v '^$' || true
fi

if [[ -f "${TEMP_SHARE}/exit_code" ]]; then
    exit $(cat "${TEMP_SHARE}/exit_code")
else
    exit 1
fi
'''

wrapper_path = BIN_DIR / "qemu-linux-aarch64"
wrapper_path.write_text(WRAPPER_SCRIPT, encoding="utf-8", newline="\n")
wrapper_path.chmod(0o755)

# Windows .cmd wrapper
if IS_WINDOWS:
    cmd_wrapper = BIN_DIR / "qemu-linux-aarch64.cmd"
    cmd_wrapper.write_text(
        '@echo off\n"%~dp0\\..\\usr\\bin\\bash.exe" -l "%~dp0\\qemu-linux-aarch64" %*\n',
        encoding="utf-8"
    )

print(f"=== qemu-linux-aarch64 build complete ===")
print(f"Kernel: {SHARE_DIR / 'vmlinuz-virt'}")
print(f"Initramfs: {SHARE_DIR / 'initramfs-base.cpio.gz'}")
print(f"Wrapper: {wrapper_path}")
