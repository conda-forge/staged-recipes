@echo off
setlocal enabledelayedexpansion

set "PS_SCRIPT=%RECIPE_DIR%\helpers\_build_qemu.ps1"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "& '%PS_SCRIPT%' " ^
    > build_qemu_output.log 2>&1

if %ERRORLEVEL% neq 0 (
    echo Error occurred during QEMU build. Check build_qemu_output.log for details.
    type build_qemu_output.log
    exit /b %ERRORLEVEL%
)

echo QEMU build log:
echo QEMU build completed successfully.
