#!/bin/bash
set -euo pipefail

# Build script for qemu-arm64 package
# Creates Alpine Linux direct-boot setup for ARM64 emulation
# Supports: osx-64 (Intel Macs), win-64 (Windows)

# Detect platform
if [[ "${OSTYPE:-}" == "msys" ]] || [[ "${OSTYPE:-}" == "cygwin" ]] || [[ -n "${MSYSTEM:-}" ]]; then
    IS_WINDOWS=1
    # On Windows, use Library/ prefix
    SHARE_DIR="${PREFIX}/Library/share/qemu-arm64"
    BIN_DIR="${PREFIX}/Library/bin"
else
    IS_WINDOWS=0
    SHARE_DIR="${PREFIX}/share/qemu-arm64"
    BIN_DIR="${PREFIX}/bin"
fi

echo "=== Building qemu-arm64 (direct kernel boot) ==="
echo "Platform: $(uname -s) (IS_WINDOWS=${IS_WINDOWS})"

# Create output directories
mkdir -p "${SHARE_DIR}"
mkdir -p "${BIN_DIR}"

# Extract netboot files (contains vmlinuz-virt, initramfs-virt, modloop-virt)
echo "Extracting Alpine netboot..."
tar -xzf "${SRC_DIR}/alpine_netboot/alpine-netboot-${alpine_version}-aarch64.tar.gz" -C "${SHARE_DIR}"

# Move kernel to expected location
mv "${SHARE_DIR}/boot/vmlinuz-virt" "${SHARE_DIR}/vmlinuz-virt"

# Create base initramfs from minirootfs
echo "Creating base initramfs from minirootfs..."
INITRAMFS_DIR=$(mktemp -d)
mkdir -p "${INITRAMFS_DIR}"

# Extract minirootfs
tar -xzf "${SRC_DIR}/alpine_rootfs/alpine-minirootfs-${alpine_version}-aarch64.tar.gz" -C "${INITRAMFS_DIR}"

# Create init script that will run the target binary
cat > "${INITRAMFS_DIR}/init" <<'INIT_EOF'
#!/bin/sh
# qemu-arm64 init script - runs target binary and exits

# Mount essential filesystems
mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t devtmpfs dev /dev

# Mount 9p share from QEMU (contains the binary to run)
mkdir -p /mnt/share
mount -t 9p -o trans=virtio,version=9p2000.L share /mnt/share 2>/dev/null || {
    echo "ERROR: Failed to mount 9p share" >&2
    poweroff -f
}

# Check if binary exists
if [ ! -f /mnt/share/binary ]; then
    echo "ERROR: No binary found at /mnt/share/binary" >&2
    poweroff -f
fi

# Read arguments if provided
ARGS=""
if [ -f /mnt/share/args ]; then
    ARGS=$(cat /mnt/share/args)
fi

# Run the binary
chmod +x /mnt/share/binary
cd /mnt/share
./binary $ARGS
EXIT_CODE=$?

# Write exit code for host to read
echo $EXIT_CODE > /mnt/share/exit_code

# Sync and poweroff
sync
poweroff -f
INIT_EOF

chmod +x "${INITRAMFS_DIR}/init"

# Create the base initramfs cpio archive
echo "Creating initramfs archive..."
cd "${INITRAMFS_DIR}"
find . | cpio -o -H newc 2>/dev/null | gzip -9 > "${SHARE_DIR}/initramfs-base.cpio.gz"

# Clean up temp directory
rm -rf "${INITRAMFS_DIR}"

# Clean up extracted netboot files we don't need
rm -rf "${SHARE_DIR}/boot" "${SHARE_DIR}/apks" 2>/dev/null || true

# Create the wrapper script
cat > "${BIN_DIR}/qemu-arm64" <<'WRAPPER_EOF'
#!/bin/bash
# qemu-arm64: Run ARM64 Linux binaries via QEMU direct boot
# Uses Alpine Linux kernel with custom initramfs
# Supports: macOS (Intel), Windows (via MSYS2)
set -euo pipefail

# Detect platform and set paths
if [[ "${OSTYPE:-}" == "msys" ]] || [[ "${OSTYPE:-}" == "cygwin" ]] || [[ -n "${MSYSTEM:-}" ]]; then
    SHARE_DIR="${CONDA_PREFIX}/Library/share/qemu-arm64"
else
    SHARE_DIR="${CONDA_PREFIX}/share/qemu-arm64"
fi
KERNEL="${SHARE_DIR}/vmlinuz-virt"
INITRAMFS_BASE="${SHARE_DIR}/initramfs-base.cpio.gz"

usage() {
    cat <<EOF
Usage: qemu-arm64 [options] program [args...]

Run ARM64 Linux binaries using QEMU system emulation with Alpine Linux.

Options:
  --version    Show version information
  --help       Show this help message

Environment variables:
  QEMU_ARM64_MEMORY   VM memory in MB (default: 256)
  QEMU_ARM64_DEBUG    Show QEMU output if set
EOF
}

version() {
    echo "qemu-arm64 (Alpine direct-boot wrapper)"
    qemu-system-aarch64 --version | head -1
}

if [[ $# -eq 0 ]]; then
    usage
    exit 1
fi

case "${1:-}" in
    --version)
        version
        exit 0
        ;;
    --help|-h)
        usage
        exit 0
        ;;
esac

BINARY="$1"
shift

# Resolve to absolute path
if [[ ! "${BINARY}" = /* ]]; then
    BINARY="$(pwd)/${BINARY}"
fi

if [[ ! -f "${BINARY}" ]]; then
    echo "Error: Binary not found: ${BINARY}" >&2
    exit 127
fi

MEMORY="${QEMU_ARM64_MEMORY:-256}"
DEBUG="${QEMU_ARM64_DEBUG:-}"

# Create temporary share directory
TEMP_SHARE=$(mktemp -d -t qemu-arm64.XXXXXX)
cleanup() {
    rm -rf "${TEMP_SHARE}"
}
trap cleanup EXIT

# Copy binary and arguments
cp "${BINARY}" "${TEMP_SHARE}/binary"
chmod +x "${TEMP_SHARE}/binary"

# Save arguments (space-separated, simple approach)
if [[ $# -gt 0 ]]; then
    printf '%s\n' "$*" > "${TEMP_SHARE}/args"
fi

# Run QEMU with direct kernel boot
QEMU_ARGS=(
    -M virt
    -cpu cortex-a57
    -m "${MEMORY}"
    -kernel "${KERNEL}"
    -initrd "${INITRAMFS_BASE}"
    -append "console=ttyAMA0 quiet panic=-1"
    -netdev user,id=net0
    -device virtio-net-pci,netdev=net0,romfile=
    -virtfs "local,path=${TEMP_SHARE},mount_tag=share,security_model=mapped-xattr,id=share"
    -nographic
    -no-reboot
)

if [[ -n "${DEBUG}" ]]; then
    qemu-system-aarch64 "${QEMU_ARGS[@]}"
else
    # Capture output, filter kernel noise
    qemu-system-aarch64 "${QEMU_ARGS[@]}" 2>&1 | grep -v '^\[' | grep -v '^$' || true
fi

# Read exit code if available
if [[ -f "${TEMP_SHARE}/exit_code" ]]; then
    exit $(cat "${TEMP_SHARE}/exit_code")
else
    # No exit code file means something went wrong
    exit 1
fi
WRAPPER_EOF

chmod +x "${BIN_DIR}/qemu-arm64"

# On Windows, also create a .cmd wrapper for easier invocation
if [[ "${IS_WINDOWS}" == "1" ]]; then
    cat > "${BIN_DIR}/qemu-arm64.cmd" <<'CMD_EOF'
@echo off
"%~dp0\..\usr\bin\bash.exe" -l "%~dp0\qemu-arm64" %*
CMD_EOF
fi

echo "=== qemu-arm64 build complete ==="
echo "Kernel: ${SHARE_DIR}/vmlinuz-virt"
echo "Initramfs: ${SHARE_DIR}/initramfs-base.cpio.gz"
echo "Wrapper: ${BIN_DIR}/qemu-arm64"
