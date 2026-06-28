@echo off
setlocal

:: Mirror upstream .goreleaser.yml: pure-Go build, no CGO. The version is
:: injected into internal/buildinfo.Version via ldflags (BuildTimestamp is
:: cosmetic and omitted on Windows). `call` guards against go shipping as a
:: .cmd shim (harmless on a real .exe).
set "CGO_ENABLED=0"
set "GOFLAGS=-mod=mod"

if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%"

call go build -trimpath ^
    -ldflags "-s -w -X github.com/nex-crm/wuphf/internal/buildinfo.Version=%PKG_VERSION%" ^
    -o "%LIBRARY_BIN%\wuphf.exe" .\cmd\wuphf
if errorlevel 1 exit 1
