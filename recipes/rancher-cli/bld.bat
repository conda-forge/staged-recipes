@echo ON

go build -v ^
    -buildmode=pie ^
    -trimpath ^
    -modcacherw ^
    -ldflags="-w -s -X main.VERSION=v%PKG_VERSION% -extldflags -static" ^
    -o "bin\%PKG_NAME%.exe" ^
    . ^
    || exit 1

if not exist "%SCRIPTS%" mkdir "%SCRIPTS%"

copy "bin\%PKG_NAME%.exe" "%SCRIPTS%"

go-licenses save "." --save_path "library_licenses" ^
    || exit 1
