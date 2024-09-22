go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\docker-credential-wincred.exe -ldflags="-s" .\wincred\cmd || goto :error
go-licenses save .\wincred\cmd --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
