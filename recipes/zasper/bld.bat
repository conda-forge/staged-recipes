@echo off
setlocal enabledelayedexpansion

set BINARY=zasper.exe

if not exist "%PREFIX%\Scripts" (
    mkdir "%PREFIX%\Scripts"
)

copy "%SRC_DIR%\%BINARY%" "%PREFIX%\Scripts\zasper.exe"

endlocal
