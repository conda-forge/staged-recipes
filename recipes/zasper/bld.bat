@echo on
setlocal enabledelayedexpansion

:: Move to the frontend directory and build
make init

:: Build the Go binary using Makefile
make build

:: Create bin directory if it doesn't exist
if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"

:: Copy the binary (adjust name if different)
copy /Y zasper.exe %PREFIX%\bin\zasper.exe
