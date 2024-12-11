@echo off

REM Create the bin directory if it doesn't exist
if not exist "%SCRIPTS%\bin" (
    mkdir "%SCRIPTS%\bin"
)

REM Copy the file and check for success
copy "%SRC_DIR%\wcurl" "%SCRIPTS%\bin\wcurl" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy wcurl to %SCRIPTS%\bin.
    exit /b 1
)
