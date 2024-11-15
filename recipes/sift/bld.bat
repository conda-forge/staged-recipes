go mod init github.com/svent/sift || goto :error
go mod tidy -e || goto :error
go mod vendor -e || goto :error
go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s" || goto :error
go-licenses save . --save_path=license-files --ignore=github.com/svent/sift || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
