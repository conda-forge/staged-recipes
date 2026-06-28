@echo off
setlocal

:: Mirror upstream .goreleaser.yml: pure-Go build, no CGO. The version is
:: injected into internal/buildinfo.Version via ldflags (BuildTimestamp is
:: cosmetic and omitted on Windows). `call` guards against go / go-licenses
:: shipping as .cmd shims (harmless on real .exe).
set "CGO_ENABLED=0"
set "GOFLAGS=-mod=mod"

if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%"

call go build -trimpath ^
    -ldflags "-s -w -X github.com/nex-crm/wuphf/internal/buildinfo.Version=%PKG_VERSION%" ^
    -o "%LIBRARY_BIN%\wuphf.exe" .\cmd\wuphf
if errorlevel 1 exit 1

:: Bundle third-party dependency licenses. Ignore wuphf's own packages: their
:: Sustainable Use License is non-OSI / non-standard, so go-licenses can't
:: classify it and `save` is fatal on unknown licenses (see SKILL.md G79).
call go-licenses save .\cmd\wuphf --save_path "%SRC_DIR%\license-files" --force ^
    --ignore github.com/nex-crm/wuphf
if errorlevel 1 exit 1
