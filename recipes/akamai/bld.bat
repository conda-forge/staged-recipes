go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s" cli/main.go || goto :error
go-licenses save ./cli --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
