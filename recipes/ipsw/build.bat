@echo off
setlocal enabledelayedexpansion

:: Enable CGO with Zig (matches upstream goreleaser)
set CGO_ENABLED=1
set CC=zig cc -target x86_64-windows-gnu
set CXX=zig c++ -target x86_64-windows-gnu
set GOFLAGS=-mod=readonly

:: Set up pkg-config for finding libraries (libusb, libheif)
set PKG_CONFIG_PATH=%LIBRARY_LIB%\pkgconfig;%PKG_CONFIG_PATH%
set CGO_CFLAGS=-I%LIBRARY_INC%
set CGO_LDFLAGS=-L%LIBRARY_LIB%

:: Build version info
set COMMIT=conda-forge-%PKG_VERSION%

:: Build ipsw
:: Note: unicorn not available on win-64
go build ^
    -ldflags "-s -w -X github.com/blacktop/ipsw/cmd/ipsw/cmd.AppVersion=%PKG_VERSION% -X github.com/blacktop/ipsw/cmd/ipsw/cmd.AppBuildCommit=%COMMIT%" ^
    -o "%LIBRARY_BIN%\ipsw.exe" ^
    .\cmd\ipsw

if errorlevel 1 exit 1

"%LIBRARY_BIN%\ipsw.exe" version
if errorlevel 1 exit 1
