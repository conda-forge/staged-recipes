@echo off
setlocal enabledelayedexpansion

call powershell "%RECIPE_DIR%\helpers\build.ps1"
if %errorlevel% neq 0 exit /b %errorlevel%
