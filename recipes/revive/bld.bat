go build -buildmode=pie -trimpath -o=%PREFIX%\bin\%PKG_NAME% -ldflags="-s -X main.version=v%PKG_VERSION%" || goto :error
go-licenses save . --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
