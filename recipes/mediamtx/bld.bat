cd cli\mediamtx || goto :error
go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s" || goto :error
go-licenses save . --save_path=%SRC_DIR%\license-files --ignore=github.com/mediamtx || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1