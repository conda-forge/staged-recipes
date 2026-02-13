@echo off
REM Build script for qemu-windows-arm64 package
REM Creates wrapper scripts for running Windows ARM64 binaries via QEMU

setlocal enabledelayedexpansion

echo === Building qemu-windows-arm64 ===

set "BIN_DIR=%PREFIX%\Library\bin"
set "SHARE_DIR=%PREFIX%\Library\share\qemu-windows-arm64"

mkdir "%BIN_DIR%" 2>nul
mkdir "%SHARE_DIR%" 2>nul

REM Create the setup script (downloads Windows ARM64 evaluation image)
(
echo #!/bin/bash
echo # qemu-windows-arm64-setup: Download and configure Windows ARM64 evaluation VM
echo set -euo pipefail
echo.
echo VM_DIR="${CONDA_PREFIX}/Library/share/qemu-windows-arm64"
echo VM_DISK="${VM_DIR}/windows-arm64.qcow2"
echo EFI_CODE="${VM_DIR}/QEMU_EFI.fd"
echo EFI_VARS="${VM_DIR}/QEMU_VARS.fd"
echo.
echo echo "=== Windows ARM64 VM Setup ==="
echo echo ""
echo echo "This will set up a Windows ARM64 evaluation VM for running ARM64 binaries."
echo echo "You will need to:"
echo echo "  1. Download Windows 11 ARM64 evaluation ISO from Microsoft"
echo echo "  2. Install Windows in the VM (one-time setup)"
echo echo "  3. Enable OpenSSH Server in Windows"
echo echo ""
echo.
echo # Check if already set up
echo if [[ -f "${VM_DISK}" ]]; then
echo     echo "VM disk already exists at: ${VM_DISK}"
echo     echo "To reset, delete this file and run setup again."
echo     exit 0
echo fi
echo.
echo # Download UEFI firmware for ARM64
echo echo "Downloading UEFI firmware..."
echo curl -fsSL -o "${EFI_CODE}" \
echo     "https://releases.linaro.org/components/kernel/uefi-linaro/latest/release/qemu64/QEMU_EFI.fd"
echo cp "${EFI_CODE}" "${EFI_VARS}"
echo.
echo # Create VM disk
echo echo "Creating VM disk (64GB sparse)..."
echo qemu-img create -f qcow2 "${VM_DISK}" 64G
echo.
echo echo ""
echo echo "=== Next Steps ==="
echo echo ""
echo echo "1. Download Windows 11 ARM64 ISO from:"
echo echo "   https://www.microsoft.com/en-us/software-download/windowsinsiderpreviewARM64"
echo echo ""
echo echo "2. Start the VM installer with:"
echo echo "   qemu-windows-arm64-install /path/to/Windows11_ARM64.iso"
echo echo ""
echo echo "3. After Windows installation, enable OpenSSH Server:"
echo echo "   Settings ^> Apps ^> Optional Features ^> Add OpenSSH Server"
echo echo "   Then start the service: net start sshd"
echo echo ""
echo echo "4. Note the VM's IP address (shown after boot) for SSH access"
echo echo ""
) > "%BIN_DIR%\qemu-windows-arm64-setup"

REM Create setup .cmd wrapper
(
echo @echo off
echo "%%~dp0\..\usr\bin\bash.exe" -l "%%~dp0\qemu-windows-arm64-setup" %%*
) > "%BIN_DIR%\qemu-windows-arm64-setup.cmd"

REM Create the install script (boots VM with ISO for installation)
(
echo #!/bin/bash
echo # qemu-windows-arm64-install: Boot VM with ISO for Windows installation
echo set -euo pipefail
echo.
echo if [[ $# -lt 1 ]]; then
echo     echo "Usage: qemu-windows-arm64-install ^<windows-arm64.iso^>"
echo     exit 1
echo fi
echo.
echo ISO_PATH="$1"
echo VM_DIR="${CONDA_PREFIX}/Library/share/qemu-windows-arm64"
echo VM_DISK="${VM_DIR}/windows-arm64.qcow2"
echo EFI_CODE="${VM_DIR}/QEMU_EFI.fd"
echo EFI_VARS="${VM_DIR}/QEMU_VARS.fd"
echo.
echo if [[ ! -f "${VM_DISK}" ]]; then
echo     echo "Error: Run qemu-windows-arm64-setup first"
echo     exit 1
echo fi
echo.
echo echo "Starting Windows ARM64 installation..."
echo echo "Install Windows, then enable OpenSSH Server."
echo echo ""
echo.
echo qemu-system-aarch64 \
echo     -M virt -cpu cortex-a76 -m 4G -smp 2 \
echo     -drive "if=pflash,format=raw,file=${EFI_CODE},readonly=on" \
echo     -drive "if=pflash,format=raw,file=${EFI_VARS}" \
echo     -drive "file=${VM_DISK},format=qcow2,if=virtio" \
echo     -drive "file=${ISO_PATH},media=cdrom" \
echo     -device virtio-net-pci,netdev=net0,romfile= \
echo     -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::5985-:5985 \
echo     -device virtio-gpu-pci \
echo     -device qemu-xhci -device usb-kbd -device usb-tablet \
echo     -display sdl
) > "%BIN_DIR%\qemu-windows-arm64-install"

REM Create install .cmd wrapper
(
echo @echo off
echo "%%~dp0\..\usr\bin\bash.exe" -l "%%~dp0\qemu-windows-arm64-install" %%*
) > "%BIN_DIR%\qemu-windows-arm64-install.cmd"

REM Create the main wrapper script
(
echo #!/bin/bash
echo # qemu-windows-arm64: Run Windows ARM64 binaries via QEMU VM
echo set -euo pipefail
echo.
echo VM_DIR="${CONDA_PREFIX}/Library/share/qemu-windows-arm64"
echo VM_DISK="${VM_DIR}/windows-arm64.qcow2"
echo EFI_CODE="${VM_DIR}/QEMU_EFI.fd"
echo EFI_VARS="${VM_DIR}/QEMU_VARS.fd"
echo SSH_PORT=2222
echo.
echo usage^(^) {
echo     cat ^<^<EOF
echo Usage: qemu-windows-arm64 [options] program.exe [args...]
echo.
echo Run Windows ARM64 binaries using QEMU system emulation.
echo.
echo Options:
echo   --help       Show this help message
echo   --start-vm   Start the VM in background
echo   --stop-vm    Stop the running VM
echo   --vm-shell   Open SSH shell to VM
echo   --setup      Run first-time setup
echo.
echo Environment:
echo   QEMU_WIN_ARM64_USER   SSH username (default: User)
echo   QEMU_WIN_ARM64_PASS   SSH password
echo.
echo First-time setup:
echo   qemu-windows-arm64 --setup
echo   qemu-windows-arm64-install /path/to/Windows11_ARM64.iso
echo EOF
echo }
echo.
echo case "${1:-}" in
echo     --help^|-h^)
echo         usage
echo         exit 0
echo         ;;
echo     --setup^)
echo         exec qemu-windows-arm64-setup
echo         ;;
echo     --start-vm^)
echo         echo "Starting Windows ARM64 VM in background..."
echo         qemu-system-aarch64 \
echo             -M virt -cpu cortex-a76 -m 4G -smp 2 \
echo             -drive "if=pflash,format=raw,file=${EFI_CODE},readonly=on" \
echo             -drive "if=pflash,format=raw,file=${EFI_VARS}" \
echo             -drive "file=${VM_DISK},format=qcow2,if=virtio" \
echo             -device virtio-net-pci,netdev=net0,romfile= \
echo             -netdev user,id=net0,hostfwd=tcp::${SSH_PORT}-:22 \
echo             -nographic -daemonize \
echo             -pidfile "${VM_DIR}/qemu.pid"
echo         echo "VM started. SSH available on localhost:${SSH_PORT}"
echo         exit 0
echo         ;;
echo     --stop-vm^)
echo         if [[ -f "${VM_DIR}/qemu.pid" ]]; then
echo             kill $(cat "${VM_DIR}/qemu.pid"^) 2^>/dev/null ^|^| true
echo             rm -f "${VM_DIR}/qemu.pid"
echo             echo "VM stopped."
echo         else
echo             echo "No running VM found."
echo         fi
echo         exit 0
echo         ;;
echo     --vm-shell^)
echo         ssh -p ${SSH_PORT} -o StrictHostKeyChecking=no localhost
echo         exit $?
echo         ;;
echo esac
echo.
echo # Run a binary
echo if [[ $# -eq 0 ]]; then
echo     usage
echo     exit 1
echo fi
echo.
echo BINARY="$1"
echo shift
echo.
echo USER="${QEMU_WIN_ARM64_USER:-User}"
echo.
echo # Check if VM is running
echo if ! nc -z localhost ${SSH_PORT} 2^>/dev/null; then
echo     echo "Error: VM not running. Start with: qemu-windows-arm64 --start-vm"
echo     exit 1
echo fi
echo.
echo # Copy binary to VM and execute
echo echo "Copying ${BINARY} to VM..."
echo scp -P ${SSH_PORT} -o StrictHostKeyChecking=no "${BINARY}" "${USER}@localhost:C:/Temp/"
echo BASENAME=$(basename "${BINARY}"^)
echo.
echo echo "Executing on Windows ARM64..."
echo ssh -p ${SSH_PORT} -o StrictHostKeyChecking=no "${USER}@localhost" "C:\\Temp\\${BASENAME}" "$@"
) > "%BIN_DIR%\qemu-windows-arm64"

REM Create main .cmd wrapper
(
echo @echo off
echo "%%~dp0\..\usr\bin\bash.exe" -l "%%~dp0\qemu-windows-arm64" %%*
) > "%BIN_DIR%\qemu-windows-arm64.cmd"

echo === qemu-windows-arm64 build complete ===
echo.
echo Wrapper scripts installed to: %BIN_DIR%
echo.
echo To set up, run: qemu-windows-arm64 --setup
