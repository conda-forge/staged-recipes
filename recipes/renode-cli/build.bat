@echo off
powershell -ExecutionPolicy Bypass -File "%RECIPE_DIR%\helpers\renode_build_with_dotnet.ps1"
if %errorlevel% neq 0 exit /b  %errorlevel%
