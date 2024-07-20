go build -trimpath -o=%LIBRARY_BIN%\%PKG_NAME%.exe -ldflags="-s -w -X github.com/cube2222/octosql/cmd.VERSION=%PKG_VERSION%" || goto :error
go-licenses save . --save_path=license-files --ignore "github.com/cube2222/octosql" --ignore "github.com/xi2/xz" || goto :error
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
