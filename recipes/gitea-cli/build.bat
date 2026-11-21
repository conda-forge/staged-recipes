@echo off
setlocal EnableDelayedExpansion

go-licenses save ./cmd/gt --save_path library_licenses
if errorlevel 1 exit /b 1

go build -v -trimpath -ldflags="-s -w -X gitea.dev/cli/internal/version.Version=%PKG_VERSION% -X gitea.dev/cli/internal/version.Tags=" -o "%LIBRARY_BIN%\gt.exe" .\cmd\gt
if errorlevel 1 exit /b 1

go run .\tools\cli-docs --out docs\generated
if errorlevel 1 exit /b 1

if not exist "%PREFIX%\share\powershell\Modules\gt" mkdir "%PREFIX%\share\powershell\Modules\gt"
copy /Y docs\generated\completion\gt.ps1 "%PREFIX%\share\powershell\Modules\gt\gt.ps1"
if errorlevel 1 exit /b 1
