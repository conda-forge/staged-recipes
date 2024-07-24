go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s -X src.elv.sh/pkg/buildinfo.VersionSuffix=" .\cmd\elvish || goto :error
go-licenses save .\cmd\elvish --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
