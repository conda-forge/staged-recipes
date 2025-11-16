@echo off
setlocal enabledelayedexpansion

REM Patch package.json to remove Unix-style MINIFY syntax for Windows compatibility
powershell -Command "(Get-Content package.json) -replace 'MINIFY=true node', 'node' | Set-Content package.json"
if errorlevel 1 exit 1

REM Build the web UI
call npm install
if errorlevel 1 exit 1

REM Set MINIFY environment variable for Windows
set MINIFY=true
call npm run build
if errorlevel 1 exit 1

REM Build the main mailpit binary
go build -v -trimpath ^
    -ldflags="-s -w -X 'github.com/axllent/mailpit/config.Version=%PKG_VERSION%'" ^
    -o "%LIBRARY_BIN%\mailpit.exe"
if errorlevel 1 exit 1

REM Build the sendmail binary
cd sendmail
if errorlevel 1 exit 1

go build -v -trimpath ^
    -ldflags="-s -w" ^
    -o "%LIBRARY_BIN%\mailpit-sendmail.exe"
if errorlevel 1 exit 1

REM Save license information
cd "%SRC_DIR%"
if errorlevel 1 exit 1

go-licenses save . --save_path .\library_licenses
if errorlevel 1 exit 1

exit 0
