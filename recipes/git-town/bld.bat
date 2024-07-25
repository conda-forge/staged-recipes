go build -trimpath -buildmode=pie -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s -X github.com/git-town/git-town/v7/src/cmd.version=v%PKG_VERSION%" || goto :error
go-licenses save . --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
