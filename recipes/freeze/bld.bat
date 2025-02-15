go build -v -o="%LIBRARY_BIN%\csvtk.exe" || goto :error
go-licenses save . --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1