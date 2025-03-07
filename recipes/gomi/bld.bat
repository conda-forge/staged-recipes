go build -buildmode=pie -trimpath -o="%LIBRARY_BIN%\gomi.exe" -ldflags="-s -w -X main.Version=%PKG_VERSION%" || goto :error
go-licenses save . --save_path=license-files --ignore github.com/mattn/go-localereader --ignore github.com/caarlos0/duration --ignore modernc.org/mathutil || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1