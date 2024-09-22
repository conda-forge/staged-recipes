go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\gum.exe -ldflags="-s -X main.Version=%PKG_VERSION%" || goto :error
go-licenses save . --save_path=license-files --ignore github.com/mattn/go-localereader || goto :error

:: Manually copy licenses that go-licenses could not download
xcopy /s %RECIPE_DIR%\license-files\* %SRC_DIR%\license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
