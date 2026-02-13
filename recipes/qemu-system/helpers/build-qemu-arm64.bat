@echo off
REM Windows build script for qemu-arm64 package
REM Calls the bash script via MSYS2 bash

set MSYS2_ARG_CONV_EXCL=*
call "%PREFIX%\Library\usr\bin\bash.exe" -l "%RECIPE_DIR%\helpers\build-qemu-arm64.sh"
if errorlevel 1 exit /b 1
