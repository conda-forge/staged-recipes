@echo ON

go build -v ^
    -buildmode=pie ^
    -trimpath ^
    -modcacherw ^
    -ldflags="-w -s -X main.VERSION=v%PKG_VERSION% -extldflags -static" ^
    -o "%SCRIPTS%\%PKG_NAME%.exe" ^
    . ^
    || exit 1


md library_licenses

cd library_licenses

go-licenses save ".." --save_path "." ^
    || exit 1
