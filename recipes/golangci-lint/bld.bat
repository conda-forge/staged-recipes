go build -buildmode=pie -trimpath -o="%LIBRARY_BIN%\%PKG_NAME%.exe" -ldflags="-s -X main.version=%PKG_VERSION%" .\cmd\%PKG_NAME% || goto :error
go-licenses save .\cmd\%PKG_NAME% --save_path=license-files --ignore github.com/golangci/golangci-lint || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
