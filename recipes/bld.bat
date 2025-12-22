@echo off
setlocal enabledelayedexpansion

:: Enable CGO for SQLite support
set CGO_ENABLED=1

:: Set Go build flags
set GOFLAGS=-buildmode=pie -trimpath -mod=readonly -modcacherw

:: Version from conda build
set VERSION=%PKG_VERSION%

:: Collect licenses from Go dependencies first
mkdir "%SRC_DIR%\library_licenses" 2>nul
go-licenses save ./... --save_path="%SRC_DIR%\library_licenses" --ignore=github.com/writefreely/writefreely
if errorlevel 1 echo Warning: go-licenses had issues, continuing...

:: Build the writefreely binary with SQLite and netgo support
:: - 'sqlite' tag enables SQLite database support (requires CGO)
:: - 'netgo' tag uses pure Go network implementations
cd cmd\writefreely
if errorlevel 1 exit /b 1

go build -v -tags="netgo sqlite" -ldflags="-s -w -X 'github.com/writefreely/writefreely.softwareVer=%VERSION%'" -o "%LIBRARY_BIN%\writefreely.exe" .
if errorlevel 1 exit /b 1

cd ..\..

:: Copy static assets and templates that WriteFreely needs at runtime
:: Users need to copy these to their working directory when running WriteFreely
mkdir "%LIBRARY_PREFIX%\share\writefreely" 2>nul
xcopy /E /I /Y pages "%LIBRARY_PREFIX%\share\writefreely\pages" 2>nul
xcopy /E /I /Y templates "%LIBRARY_PREFIX%\share\writefreely\templates" 2>nul
xcopy /E /I /Y static "%LIBRARY_PREFIX%\share\writefreely\static" 2>nul
xcopy /E /I /Y keys "%LIBRARY_PREFIX%\share\writefreely\keys" 2>nul
copy /Y schema.sql "%LIBRARY_PREFIX%\share\writefreely\" 2>nul
copy /Y sqlite.sql "%LIBRARY_PREFIX%\share\writefreely\" 2>nul

echo Build completed successfully!
