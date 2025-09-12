@echo off
setlocal EnableDelayedExpansion

:: Build the project
call npm ci
if errorlevel 1 exit /b 1

call npm run build
if errorlevel 1 exit /b 1

:: Create directories
if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"
if not exist "%PREFIX%\lib\node_modules\%PKG_NAME%" mkdir "%PREFIX%\lib\node_modules\%PKG_NAME%"

:: Copy the bundled executable
copy bundle\gemini.js "%PREFIX%\lib\node_modules\%PKG_NAME%\"
if errorlevel 1 exit /b 1

:: Create the batch wrapper
echo @echo off > "%PREFIX%\bin\gemini.bat"
echo node "%PREFIX%\lib\node_modules\%PKG_NAME%\gemini.js" %%* >> "%PREFIX%\bin\gemini.bat"
