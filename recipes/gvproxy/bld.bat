go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s -H=windowsgui" .\cmd\%PKG_NAME% || goto :error
go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\sshproxy.exe -ldflags="-s -H=windowsgui" .\cmd\win-sshproxy || goto :error
go-licenses save .\cmd\%PKG_NAME% --save_path=license-files_%PKG_NAME% || goto :error
go-licenses save .\cmd\win-sshproxy --save_path=license-files_win-sshproxy || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
