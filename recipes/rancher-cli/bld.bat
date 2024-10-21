@echo ON

if not exist "%SCRIPTS%" mkdir "%SCRIPTS%"

go build -v ^
    -buildmode=pie ^
    -trimpath ^
    -modcacherw ^
    -ldflags="-w -s -X main.VERSION=v%PKG_VERSION% -extldflags -static" ^
    -o "%SCRIPTS%\%PKG_NAME%.exe" ^
    . ^
    || exit 1

go-licenses save ^
    "." ^
    --save_path "%SRC_DIR%\library_licenses\" ^
    || exit 1
