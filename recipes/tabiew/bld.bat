@echo off
setlocal enabledelayedexpansion

REM Build the Rust binary with cargo
cargo install --locked --root "%PREFIX%" --path .
if errorlevel 1 exit 1

REM Verify the binary was installed
if not exist "%LIBRARY_BIN%\tw.exe" (
    echo Error: tw.exe was not created
    exit 1
)

echo Build successful!