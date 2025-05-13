@echo off
setlocal enabledelayedexpansion

REM Print debug information
echo SRC_DIR: %SRC_DIR%
echo PREFIX: %PREFIX%

REM Set the binary name
set BINARY=zasper.exe

REM Make sure the destination directory exists
if not exist "%PREFIX%\Scripts" (
    mkdir "%PREFIX%\Scripts"
)

REM Copy binary to Scripts
copy "%SRC_DIR%\%BINARY%" "%PREFIX%\Scripts\zasper.exe"

REM Optional: run the binary to verify it works
echo Running the binary:
"%PREFIX%\Scripts\zasper.exe" --help


REM Optional: show that the file was copied
echo === Contents of %PREFIX%\Scripts ===
dir "%PREFIX%\Scripts"

endlocal
