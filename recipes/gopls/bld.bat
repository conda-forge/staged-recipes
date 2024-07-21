go build -buildmode=pie -trimpath -o="%LIBRARY_BIN%\%PKG_NAME%.exe" -ldflags="-s" .\gopls || goto :error
go-licenses save .\gopls --save_path=license-files --ignore golang.org/x/tools/gopls || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
