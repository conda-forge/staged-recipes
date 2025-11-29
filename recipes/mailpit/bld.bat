@echo off
setlocal enabledelayedexpansion

:: Patch package.json to remove Unix-style MINIFY syntax for Windows compatibility
powershell -Command "(Get-Content package.json) -replace 'MINIFY=true node', 'node' | Set-Content package.json" || goto :error

:: Build the web UI
call npm install || goto :error

:: Set MINIFY environment variable for Windows
set MINIFY=true
call npm run build || goto :error

:: Build the main mailpit binary
go build -v ^
    -ldflags="-s -w -X 'github.com/axllent/mailpit/config.Version=%PKG_VERSION%'" ^
    -o "%LIBRARY_BIN%\mailpit.exe" || goto :error

:: Build the sendmail binary
cd sendmail

go build -v ^
    -ldflags="-s -w" ^
    -o "%LIBRARY_BIN%\mailpit-sendmail.exe" || goto :error

REM Save license information
cd "%SRC_DIR%"

go-licenses save . --save_path .\library_licenses || goto :error

goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1
