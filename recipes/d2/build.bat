go build -ldflags "-s -w -X oss.terrastruct.com/d2/lib/version.Version=%PKG_VERSION%" -o %LIBRARY_BIN%\d2.exe || exit 1

if exist "%TEMP%\library_licenses" (
    rmdir /s /q "%TEMP%\library_licenses"
)

go-licenses save . --ignore "github.com/golang/freetype" --save_path "%TEMP%\library_licenses"

if exist "%TEMP%\library_licenses" (
    move /y "%TEMP%\library_licenses" ".\library_licenses"
)