@echo off

REM Copy wcurl and the trampoline script (wcurl.cmd) and check for success

copy "%SRC_DIR%\wcurl" "%LIBRARY_BIN%\wcurl" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy wcurl to %LIBRARY_BIN%.
    exit /b 1
)

copy "%RECIPE_DIR%\wcurl.cmd" "%LIBRARY_BIN%\wcurl.cmd" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy wcurl.cmd to %LIBRARY_BIN%.
    exit /b 1
)
