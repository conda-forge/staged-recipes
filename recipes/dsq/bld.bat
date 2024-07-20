go build -buildmode=pie -trimpath -o="%LIBRARY_BIN%\%PKG_NAME%.exe" -ldflags="LDFLAGS=-s -X main.Version=%PKG_VERSION%" || goto :error
go-licenses save . --save_path=license-files --ignore github.com/multiprocessio/datastation/runner || goto :error
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
