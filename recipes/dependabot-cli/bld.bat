go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\dependabot.exe -ldflags="-s" .\cmd\dependabot || goto :error
go-licenses save .\cmd\dependabot --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
