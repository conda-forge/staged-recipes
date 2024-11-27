set -ex
pushd src

go build -ldflags "-s -w -X oss.terrastruct.com/d2/lib/version.Version=$PKG_VERSION" -o $PREFIX/bin/d2

go-licenses save . --ignore "github.com/golang/freetype" --save_path ../library_licenses
