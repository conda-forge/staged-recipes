go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\jsonnet.exe -ldflags="-s" .\cmd\jsonnet || goto :error
go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\jsonnetfmt.exe -ldflags="-s" .\cmd\jsonnetfmt || goto :error
go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\jsonnet-lint.exe -ldflags="-s" .\cmd\jsonnet-lint || goto :error
go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin/jsonnet-deps.exe -ldflags="-s" .\cmd\jsonnet-deps || goto :error
go-licenses save . --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
