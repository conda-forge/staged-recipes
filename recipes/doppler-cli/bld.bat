@echo on

go build -buildmode=pie -trimpath -modcacherw -o=%LIBRARY_PREFIX%\bin\doppler.exe -ldflags="-s" || goto :error
go-licenses save . --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
