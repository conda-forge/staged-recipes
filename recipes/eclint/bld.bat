go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\eclint.exe -ldflags="-s" .\cmd\eclint || goto :error
go-licenses save .\cmd\eclint. --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
