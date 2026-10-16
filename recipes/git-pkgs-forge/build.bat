@echo on
@setlocal EnableDelayedExpansion

go build -o=%LIBRARY_PREFIX%\bin\forge.exe -ldflags="-s -w -X github.com/git-pkgs/forge/internal/cli.Version=%PKG_VERSION%" .\cmd\forge || goto :error

go-licenses save .\cmd\forge --save_path=license-files || goto :error

goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1
