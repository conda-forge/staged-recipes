@echo off

powershell -Command "& { %RECIPE_DIR%\helpers\build.ps1 }"
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
