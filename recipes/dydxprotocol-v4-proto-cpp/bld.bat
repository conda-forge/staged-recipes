@echo off

powershell -Command "& { %RECIPE_DIR%\helpers\build.ps1 }"
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

powershell -Command "& { %RECIPE_DIR%\helpers\verify_installed_lib.ps1 }"
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
