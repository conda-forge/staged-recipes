go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s" .\cmd\vale || goto :error
go-licenses save .\cmd\vale --save_path=license-files --ignore github.com/xi2/xz || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
