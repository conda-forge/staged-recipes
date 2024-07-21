go build -buildmode=pie -trimpath -o="%LIBRARY_BIN%\glow.exe" -ldflags="-s -w -X main.Version=%PKG_VERSION%" || goto :error
go-licenses save . --save_path=license-files --ignore github.com/mattn/go-localereader || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
