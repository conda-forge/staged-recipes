@echo off
setlocal

call powershell -ExecutionPolicy Bypass -File %RECIPE_DIR%\helpers\build_install_qemu.ps1
if %errorlevel% neq 0 exit /b %errorlevel%
