#!/usr/bin/env python3
"""Build script for qemu-linux-aarch64 package (Alpine direct-boot wrapper).

Creates Alpine Linux direct-boot setup for ARM64 emulation.
Supports: osx-64 (Intel Macs), win-64 (Windows)
"""
import gzip
import os
import shutil
import stat
import sys
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


def write_cpio_newc(output_file, root_path: Path):
    """Write a cpio archive in newc format (pure Python, no external cpio needed).

    This implements the SVR4 'newc' format used by Linux initramfs.
    Format: 6-byte magic, then 13 8-character hex fields, filename, padding, data, padding.
    """
    root_path = Path(root_path).resolve()
    ino_counter = 300000  # Start inode counter

    def write_entry(f, path: Path, name: str):
        nonlocal ino_counter

        st = path.lstat()
        mode = st.st_mode
        nlink = st.st_nlink if stat.S_ISDIR(mode) else 1

        # File data
        if stat.S_ISREG(mode):
            data = path.read_bytes()
            filesize = len(data)
        elif stat.S_ISLNK(mode):
            data = os.readlink(path).encode('utf-8')
            filesize = len(data)
        else:
            data = b''
            filesize = 0

        # Ensure name ends with null and calculate namesize
        name_bytes = name.encode('utf-8') + b'\x00'
        namesize = len(name_bytes)

        # Header: magic + 13 fields (8 hex chars each)
        header = (
            f"070701"                    # magic (newc)
            f"{ino_counter:08X}"         # ino
            f"{mode:08X}"                # mode
            f"{0:08X}"                   # uid (0 = root)
            f"{0:08X}"                   # gid (0 = root)
            f"{nlink:08X}"               # nlink
            f"{0:08X}"                   # mtime
            f"{filesize:08X}"            # filesize
            f"{0:08X}"                   # devmajor
            f"{0:08X}"                   # devminor
            f"{0:08X}"                   # rdevmajor
            f"{0:08X}"                   # rdevminor
            f"{namesize:08X}"            # namesize
            f"{0:08X}"                   # check (always 0 for newc)
        ).encode('ascii')

        f.write(header)
        f.write(name_bytes)

        # Pad to 4-byte boundary after header+name
        header_plus_name = 110 + namesize  # 110 = header size
        pad_after_name = (4 - (header_plus_name % 4)) % 4
        f.write(b'\x00' * pad_after_name)

        # Write data
        if data:
            f.write(data)
            # Pad data to 4-byte boundary
            pad_after_data = (4 - (filesize % 4)) % 4
            f.write(b'\x00' * pad_after_data)

        ino_counter += 1

    # Collect all entries (directories first, then files)
    entries = []
    for path in sorted(root_path.rglob('*')):
        rel = path.relative_to(root_path)
        name = str(rel).replace('\\', '/')
        entries.append((path, name))

    # Sort: directories first (by depth), then files
    dirs = [(p, n) for p, n in entries if p.is_dir()]
    files = [(p, n) for p, n in entries if not p.is_dir()]

    with open(output_file, 'wb') as raw_f:
        with gzip.GzipFile(fileobj=raw_f, mode='wb', compresslevel=9) as f:
            # Write root directory entry
            write_entry(f, root_path, '.')

            # Write directories
            for path, name in sorted(dirs, key=lambda x: x[1].count('/')):
                write_entry(f, path, name)

            # Write files and symlinks
            for path, name in files:
                write_entry(f, path, name)

            # Write trailer
            trailer_name = b'TRAILER!!!\x00'
            trailer_header = (
                f"070701"
                f"{0:08X}" f"{0:08X}" f"{0:08X}" f"{0:08X}"
                f"{1:08X}" f"{0:08X}" f"{0:08X}" f"{0:08X}"
                f"{0:08X}" f"{0:08X}" f"{0:08X}"
                f"{len(trailer_name):08X}" f"{0:08X}"
            ).encode('ascii')
            f.write(trailer_header)
            f.write(trailer_name)
            # Pad to 4-byte boundary
            total = 110 + len(trailer_name)
            f.write(b'\x00' * ((4 - (total % 4)) % 4))

SHARE_DIR.mkdir(parents=True, exist_ok=True)
BIN_DIR.mkdir(parents=True, exist_ok=True)

# Source directories (rattler-build extracts contents directly to target_directory)
NETBOOT_DIR = SRC_DIR / "alpine_netboot"
ROOTFS_DIR = SRC_DIR / "alpine_rootfs"

# Copy kernel from extracted netboot
print("Copying Alpine kernel...")
kernel_src = NETBOOT_DIR / "boot" / "vmlinuz-virt"
kernel_dst = SHARE_DIR / "vmlinuz-virt"
shutil.copy2(str(kernel_src), str(kernel_dst))

# Create initramfs from minirootfs (already extracted)
print("Creating base initramfs from minirootfs...")
with tempfile.TemporaryDirectory() as initramfs_dir:
    initramfs_path = Path(initramfs_dir)

    # Copy minirootfs contents (already extracted by rattler-build)
    shutil.copytree(ROOTFS_DIR, initramfs_path, dirs_exist_ok=True)

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

    # Create cpio archive using pure Python (no external cpio dependency)
    print("Creating initramfs archive...")
    initramfs_out = SHARE_DIR / "initramfs-base.cpio.gz"
    write_cpio_newc(initramfs_out, initramfs_path)


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
