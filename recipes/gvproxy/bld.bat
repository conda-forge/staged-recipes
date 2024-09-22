go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\gvproxy.exe -ldflags="-s -H=windowsgui" .\cmd\gvproxy || goto :error
go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\sshproxy.exe -ldflags="-s -H=windowsgui" .\cmd\win-sshproxy || goto :error
go-licenses save .\cmd\gvproxy --save_path=license-files_gvproxy || goto :error
go-licenses save .\cmd\win-sshproxy --save_path=license-files_win-sshproxy || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
