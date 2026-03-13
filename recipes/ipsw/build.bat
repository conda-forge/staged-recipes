@echo off
setlocal enabledelayedexpansion

:: Build version info
set "COMMIT=conda-forge-%PKG_VERSION%" || goto :error
set "GOFLAGS=%GOFLAGS% -mod=readonly" || goto :error

go build -ldflags "-s -w -X github.com\blacktop\ipsw\cmd\ipsw\cmd.AppVersion=%PKG_VERSION% -X github.com\blacktop\ipsw\cmd\ipsw\cmd.AppBuildCommit=%COMMIT%" -o "%PREFIX%\Library\bin\ipsw.exe" .\cmd\ipsw || goto :error
go-licenses save . --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
