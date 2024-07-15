set CGO_ENABLED=0
set LDFLAGS="-s"
go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags=%LDFLAGS% || goto :error
go-licenses save . --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
