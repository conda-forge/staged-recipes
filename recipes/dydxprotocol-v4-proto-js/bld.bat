@echo off
powershell -Command "Invoke-Expression -Command (Get-Content -Path %~dp0\bld.ps1 -Raw)"
if errorlevel 1 exit 1
