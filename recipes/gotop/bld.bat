set CGO_CFLAGS="-Wno-undef-prefix" || goto :error
go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s" .\cmd\gotop || goto :error
go-licenses save .\cmd\gotop --save_path=license-files ^
    --ignore github.com/xxxserxxx/gotop/v4 ^
    --ignore github.com/xxxserxxx/gotop/v4/colorschemes ^
    --ignore github.com/xxxserxxx/gotop/v4/devices ^
    --ignore github.com/xxxserxxx/gotop/v4/termui ^
    --ignore github.com/xxxserxxx/gotop/v4/utils ^
    --ignore github.com/xxxserxxx/gotop/v4/widgets ^
    --ignore github.com/xxxserxxx/gotop/v4/termui/drawille-go || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
