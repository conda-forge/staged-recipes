@echo off

REM Create the bin directory if it doesn't exist
if not exist "%PREFIX%\bin" (
    mkdir "%PREFIX%\bin"
)

REM Copy the file and check for success
copy "%SRC_DIR%\wcurl" "%PREFIX%\bin\wcurl" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy wcurl to %PREFIX%\bin.
    exit /b 1
)