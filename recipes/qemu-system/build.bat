@echo off
setlocal

call powershell -ExecutionPolicy Bypass -File %~dp0\build_install_qemu.ps1
if %errorlevel% neq 0 exit /b %errorlevel%
