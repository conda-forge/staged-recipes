@echo off

REM Copy the file and check for success
copy "%SRC_DIR%\wcurl" "%LIBRARY_BIN%\wcurl" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy wcurl to %LIBRARY_BIN%.
    exit /b 1
)
