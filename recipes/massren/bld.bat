set GOPROXY=https://proxy.golang.org || goto :error
go mod init || goto :error
go mod tidy || goto :error
go mod vendor || goto :error
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w" || goto :error
go-licenses save . --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
