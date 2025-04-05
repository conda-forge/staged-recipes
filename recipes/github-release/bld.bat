@echo on

go mod init github-release || goto :error
go mod vendor -e || goto :error
go mod tidy -e || goto :error
go build -modcacherw -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s -w" || goto :error
go-licenses save . --save_path=license-files || goto :error

goto :eof

:error
echo Failed with #%errorlevel%.
exit 1
