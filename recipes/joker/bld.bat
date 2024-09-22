go generate ./... || goto :error
go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s -X main.version=v%PKG_VERSION%" || goto :error
go-licenses save . --save_path=license-files --ignore github.com/candid82/joker || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
