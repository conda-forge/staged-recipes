go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s -X github.com/apache/skywalking-eyes/commands.version=%PKG_VERSION%" .\cmd\license-eye || goto :error
go-licenses save .\cmd\license-eye --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
