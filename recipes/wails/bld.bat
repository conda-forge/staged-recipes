cd v2
go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s" .\cmd\wails || goto :error
go-licenses save .\cmd\wails --save_path=%SRC_DIR%\license-files ^
    --ignore github.com/wailsapp/wails ^
    --ignore github.com/flytam/filenamify || goto :error

:: Manually copy licenses that go-licenses could not download
xcopy /s %RECIPE_DIR%\license-files\* %SRC_DIR%\license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
