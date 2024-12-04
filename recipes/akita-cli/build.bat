@echo on

go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\akita-cli -ldflags="-s" || goto :error
go-licenses save . --save_path=license-files --ignore github.com/akitasoftware/plugin-flickr || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
