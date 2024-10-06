make build-tags || goto :error
go-licenses save .\cmd\micro --save_path=license-files || goto :error

mkdir %LIBRARY_PREFIX%\bin || goto :error
copy micro.exe %LIBRARY_PREFIX%\bin || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
