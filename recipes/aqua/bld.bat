@echo on

go build -buildmode=pie -trimpath -modcacherw -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s" .\cmd\aqua || goto :error
go-licenses save .\cmd\aqua --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
