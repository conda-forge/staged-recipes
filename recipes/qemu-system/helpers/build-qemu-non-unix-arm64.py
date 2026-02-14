#!/usr/bin/env python3
"""Build script for qemu-arm64 package (Windows ARM64 VM wrapper)."""
import os
from pathlib import Path

PREFIX = Path(os.environ["PREFIX"])
BIN_DIR = PREFIX / "Library" / "bin"
SHARE_DIR = PREFIX / "Library" / "share" / "qemu-windows-arm64"

BIN_DIR.mkdir(parents=True, exist_ok=True)
SHARE_DIR.mkdir(parents=True, exist_ok=True)

# Setup script (downloads UEFI firmware, creates VM disk)
SETUP_SCRIPT = r'''#!/bin/bash
# qemu-windows-arm64-setup: Download and configure Windows ARM64 evaluation VM
set -euo pipefail

VM_DIR="${CONDA_PREFIX}/Library/share/qemu-windows-arm64"
VM_DISK="${VM_DIR}/windows-arm64.qcow2"
EFI_CODE="${VM_DIR}/QEMU_EFI.fd"
EFI_VARS="${VM_DIR}/QEMU_VARS.fd"

echo "=== Windows ARM64 VM Setup ==="
echo ""
echo "This will set up a Windows ARM64 evaluation VM for running ARM64 binaries."

if [[ -f "${VM_DISK}" ]]; then
    echo "VM disk already exists at: ${VM_DISK}"
    echo "To reset, delete this file and run setup again."
    exit 0
fi

echo "Downloading UEFI firmware..."
curl -fsSL -o "${EFI_CODE}" \
    "https://releases.linaro.org/components/kernel/uefi-linaro/latest/release/qemu64/QEMU_EFI.fd"
cp "${EFI_CODE}" "${EFI_VARS}"

echo "Creating VM disk (64GB sparse)..."
qemu-img create -f qcow2 "${VM_DISK}" 64G

echo ""
echo "=== Next Steps ==="
echo "1. Download Windows 11 ARM64 ISO from Microsoft"
echo "2. Run: qemu-windows-arm64-install /path/to/Windows11_ARM64.iso"
echo "3. After install, enable OpenSSH Server in Windows"
'''

# Install script (boots VM with ISO)
INSTALL_SCRIPT = r'''#!/bin/bash
# qemu-windows-arm64-install: Boot VM with ISO for Windows installation
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: qemu-windows-arm64-install <windows-arm64.iso>"
    exit 1
fi

ISO_PATH="$1"
VM_DIR="${CONDA_PREFIX}/Library/share/qemu-windows-arm64"
VM_DISK="${VM_DIR}/windows-arm64.qcow2"
EFI_CODE="${VM_DIR}/QEMU_EFI.fd"
EFI_VARS="${VM_DIR}/QEMU_VARS.fd"

if [[ ! -f "${VM_DISK}" ]]; then
    echo "Error: Run qemu-windows-arm64-setup first"
    exit 1
fi

echo "Starting Windows ARM64 installation..."
qemu-system-aarch64 \
    -M virt -cpu cortex-a76 -m 4G -smp 2 \
    -drive "if=pflash,format=raw,file=${EFI_CODE},readonly=on" \
    -drive "if=pflash,format=raw,file=${EFI_VARS}" \
    -drive "file=${VM_DISK},format=qcow2,if=virtio" \
    -drive "file=${ISO_PATH},media=cdrom" \
    -device virtio-net-pci,netdev=net0,romfile= \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -device virtio-gpu-pci \
    -device qemu-xhci -device usb-kbd -device usb-tablet \
    -display sdl
'''

# Main wrapper script
MAIN_SCRIPT = r'''#!/bin/bash
# qemu-windows-arm64: Run Windows ARM64 binaries via QEMU VM
set -euo pipefail

VM_DIR="${CONDA_PREFIX}/Library/share/qemu-windows-arm64"
VM_DISK="${VM_DIR}/windows-arm64.qcow2"
EFI_CODE="${VM_DIR}/QEMU_EFI.fd"
EFI_VARS="${VM_DIR}/QEMU_VARS.fd"
SSH_PORT=2222

usage() {
    cat <<'EOF'
Usage: qemu-windows-arm64 [options] program.exe [args...]

Run Windows ARM64 binaries using QEMU system emulation.

Options:
  --help       Show this help message
  --start-vm   Start the VM in background
  --stop-vm    Stop the running VM
  --vm-shell   Open SSH shell to VM
  --setup      Run first-time setup

First-time setup:
  qemu-windows-arm64-setup
  qemu-windows-arm64-install /path/to/Windows11_ARM64.iso
EOF
}

case "${1:-}" in
    --help|-h)
        usage
        exit 0
        ;;
    --setup)
        exec qemu-windows-arm64-setup
        ;;
    --start-vm)
        echo "Starting Windows ARM64 VM in background..."
        qemu-system-aarch64 \
            -M virt -cpu cortex-a76 -m 4G -smp 2 \
            -drive "if=pflash,format=raw,file=${EFI_CODE},readonly=on" \
            -drive "if=pflash,format=raw,file=${EFI_VARS}" \
            -drive "file=${VM_DISK},format=qcow2,if=virtio" \
            -device virtio-net-pci,netdev=net0,romfile= \
            -netdev user,id=net0,hostfwd=tcp::${SSH_PORT}-:22 \
            -nographic -daemonize \
            -pidfile "${VM_DIR}/qemu.pid"
        echo "VM started. SSH available on localhost:${SSH_PORT}"
        exit 0
        ;;
    --stop-vm)
        if [[ -f "${VM_DIR}/qemu.pid" ]]; then
            kill "$(cat "${VM_DIR}/qemu.pid")" 2>/dev/null || true
            rm -f "${VM_DIR}/qemu.pid"
            echo "VM stopped."
        else
            echo "No running VM found."
        fi
        exit 0
        ;;
    --vm-shell)
        ssh -p ${SSH_PORT} -o StrictHostKeyChecking=no localhost
        exit $?
        ;;
esac

if [[ $# -eq 0 ]]; then
    usage
    exit 1
fi

BINARY="$1"
shift
USER="${QEMU_WIN_ARM64_USER:-User}"

if ! nc -z localhost ${SSH_PORT} 2>/dev/null; then
    echo "Error: VM not running. Start with: qemu-windows-arm64 --start-vm"
    exit 1
fi

echo "Copying ${BINARY} to VM..."
scp -P ${SSH_PORT} -o StrictHostKeyChecking=no "${BINARY}" "${USER}@localhost:C:/Temp/"
BASENAME="$(basename "${BINARY}")"

echo "Executing on Windows ARM64..."
ssh -p ${SSH_PORT} -o StrictHostKeyChecking=no "${USER}@localhost" "C:\\Temp\\${BASENAME}" "$@"
'''

# CMD wrapper template
CMD_WRAPPER = '@echo off\n"%~dp0\\..\\usr\\bin\\bash.exe" -l "%~dp0\\{name}" %*\n'

def write_script(name: str, content: str) -> None:
    """Write bash script and its .cmd wrapper."""
    # Write bash script
    script_path = BIN_DIR / name
    script_path.write_text(content, encoding="utf-8", newline="\n")

    # Write .cmd wrapper
    cmd_path = BIN_DIR / f"{name}.cmd"
    cmd_path.write_text(CMD_WRAPPER.format(name=name), encoding="utf-8")

    print(f"Installed: {name}")

write_script("qemu-windows-arm64-setup", SETUP_SCRIPT)
write_script("qemu-windows-arm64-install", INSTALL_SCRIPT)
write_script("qemu-windows-arm64", MAIN_SCRIPT)

print(f"\n=== qemu-arm64 build complete ===")
print(f"Scripts installed to: {BIN_DIR}")
