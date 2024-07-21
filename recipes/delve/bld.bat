go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\dlv.exe -ldflags="-s -w" .\cmd\dlv || goto :error
go-licenses save .\cmd\dlv --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
