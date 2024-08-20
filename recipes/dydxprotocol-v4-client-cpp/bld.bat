@echo off

powershell -Command helpers\build.ps1
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
