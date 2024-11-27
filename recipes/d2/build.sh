set -ex

go build -ldflags "-s -w -X oss.terrastruct.com/d2/lib/version.Version=$PKG_VERSION" -o $PREFIX/bin/d2


# when specifying save_path directly, go-licenses runs into a recursion and throws a "file name too long" error
# non-standard license: freetype
rm -rf /tmp/library_licenses
go-licenses save . --ignore "github.com/golang/freetype" --save_path /tmp/library_licenses
mv /tmp/library_licenses ./library_licenses