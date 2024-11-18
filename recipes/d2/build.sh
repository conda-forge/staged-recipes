set -ex

echo $(which go)
ci/release/build.sh --host-only --install
# ls -lah ./ci/release/build/<version>/d2-<VERSION>-<OS>-<ARCH>.tar.gz


# when specifying save_path directly, go-licenses runs into a recursion and throws a "file name too long" error
# non-standard license: freetype
rm -rf /tmp/library_licenses
go-licenses save . --ignore "github.com/golang/freetype" --save_path /tmp/library_licenses
mv /tmp/library_licenses ./library_licenses