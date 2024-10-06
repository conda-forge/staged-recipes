go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s" .\cmd\influx || goto :error
go-licenses save . --save_path=license-files .\cmd\influx || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
