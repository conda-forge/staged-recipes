@echo off

REM Copy the file and check for success
copy "%SRC_DIR%\wcurl" "%SCRIPTS%\wcurl" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy wcurl to %SCRIPTS%\bin.
    exit /b 1
)