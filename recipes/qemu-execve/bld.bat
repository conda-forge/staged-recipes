@echo off
setlocal enabledelayedexpansion

set "PS_SCRIPT=%RECIPE_DIR%\helpers\_build_qemu.ps1"
set "BUILD_DIR=%build_dir%"
set "INSTALL_DIR=%install_dir%"
set "QEMU_ARGS=--target-list=aarch64-softmmu"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "& '%PS_SCRIPT%' -build_dir '%BUILD_DIR%' -install_dir '%INSTALL_DIR%' -qemu_args '%QEMU_ARGS%'" ^
    > build_qemu_output.log 2>&1

if %ERRORLEVEL% neq 0 (
    echo Error occurred during QEMU build. Check build_qemu_output.log for details.
    exit /b %ERRORLEVEL%
)

echo QEMU build log:
type build_qemu_output.log
echo QEMU build completed successfully.
