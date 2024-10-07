go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s" .\cmd\cue || goto :error
go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s" .\cmd\cuepls || goto :error

go-licenses save .\cmd\cue --save_path=license-files_cue || goto :error
go-licenses save .\cmd\cuepls --save_path=license-files_cuepls || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
