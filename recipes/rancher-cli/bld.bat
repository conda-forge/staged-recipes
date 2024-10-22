@echo ON

go build -v ^
    -buildmode=pie ^
    -trimpath ^
    -modcacherw ^
    -ldflags="-w -s -X main.VERSION=v%PKG_VERSION% -extldflags -static" ^
    -o "%SCRIPTS%\rancher.exe" ^
    . ^
    || exit 1

dir "%SCRIPTS%\rancher.exe"

go-licenses save . --save_path library_licenses ^
    || exit 1
