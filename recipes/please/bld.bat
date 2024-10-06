go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\plz.exe -ldflags="-s" .\src\please.go || goto :error
mklink . .\src\please.go || goto :error
go-licenses save . --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
