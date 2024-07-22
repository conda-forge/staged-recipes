go build -buildmode=pie -trimpath -o=%LIBRARY_BIN%\%PKG_NAME%.exe -ldflags="-s -X main.version=v%PKG_VERSION%" || goto :error
go-licenses save . --save_path=license-files --ignore github.com/tj/go-update || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
