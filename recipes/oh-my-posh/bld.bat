cd src || goto :error
go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME% -ldflags="-s -X main.Version=%PKG_VERSION%" || goto :error
go-licenses save . --save_path=..\license-files ^
    --ignore github.com/golang/freetype/raster ^
    --ignore github.com/golang/freetype/truetype ^
    --ignore github.com/jandedobbeleer/oh-my-posh ^
    --ignore github.com/mattn/go-localereader || goto :error

cd %SRC_DIR% || goto :error
xcopy /s /t /e themes %LIBRARY_PREFIX% || goto :error
mkdir %LIBRARY_PREFIX%\share\%PKG_NAME% || goto :error
mklink %LIBRARY_PREFIX%\share\%PKG_NAME% %LIBRARY_PREFIX%\themes || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
