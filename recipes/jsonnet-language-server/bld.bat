go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s -w" || goto :error
go-licenses save . --save_path=license-files --ignore github.com/grafana/jsonnet-language-server || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
