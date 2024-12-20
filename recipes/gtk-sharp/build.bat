@echo off

call powershell -ExecutionPolicy Bypass -File %SRC_DIR%\helpers\build.ps1
if %errorlevel% neq 0 exit /b %errorlevel%
