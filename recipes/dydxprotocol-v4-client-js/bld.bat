@echo off
powershell -Command "Invoke-Expression -Command (Get-Content -Path %RECIPE_DIR%\helpers\bld.ps1 -Raw)"
if errorlevel 1 exit 1
