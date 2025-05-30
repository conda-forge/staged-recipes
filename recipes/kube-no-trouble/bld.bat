go build -buildmode=pie -trimpath -o %LIBRARY_PREFIX%\bin\kubent.exe -ldflags="-s -X main.version=%PKG_VERSION% -X main.gitSha=conda-forge" .\cmd\kubent || goto :error
go-licenses save .\cmd\kubent --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
