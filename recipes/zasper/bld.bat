@echo on
setlocal enabledelayedexpansion

:: Ensure Go modules mode is enabled
set GO111MODULE=on

:: Create a temporary GOPATH to avoid go.mod conflict
set GOPATH=%TEMP%\gopath

:: Move to the frontend directory and build
make init

:: Build the Go binary using Makefile
make build

:: Create bin directory if it doesn't exist
if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"

:: Copy the binary (adjust name if different)
copy /Y bin\zasper.exe %PREFIX%\bin\zasper.exe
