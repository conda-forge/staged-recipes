pushd src

go build -ldflags "-s -w -X oss.terrastruct.com/d2/lib/version.Version=%PKG_VERSION%" -o %LIBRARY_BIN%\d2.exe || exit 1

go-licenses save . --ignore "github.com/golang/freetype" --save_path ..\library_licenses || exit 1
