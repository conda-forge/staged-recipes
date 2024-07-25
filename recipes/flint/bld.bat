set GOPROXY=https://proxy.golang.org
go mod init flint
go mod edit -replace github.com/codegangsta/cli=github.com/urfave/cli@v1
go mod tidy
go mod vendor

go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s" || goto :error
go-licenses save . --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
