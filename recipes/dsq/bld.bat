go mod edit -replace github.com/mattn/go-ieproxy@v0.0.9=github.com/mattn/go-ieproxy@v0.0.11 || goto :error
go mod tidy -e || goto :error
go mod vendor -e || goto :error
build -buildmode=pie -trimpath -o="%LIBRARY_BIN%\%PKG_NAME%.exe" -ldflags="LDFLAGS=-s -X main.Version=%PKG_VERSION%" || goto :error
go-licenses save . --save_path=license-files --ignore github.com/multiprocessio/datastation/runner || goto :error
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
