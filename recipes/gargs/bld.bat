@echo on

go mod init github-release || goto :error
go mod tidy -e || goto :error
go build -modcacherw -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w" || goto :error
go-licenses save . --save_path=license-files || goto :error

goto :eof

:error
echo Failed with #%errorlevel%.
exit 1
