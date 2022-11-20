set -ex

./autogen.sh
./configure --prefix="$PREFIX" --enable-shared
[[ "$target_platform" == "win-64" ]] && patch_libtool
make -j${CPU_COUNT}
make install

[[ "$target_platform" != "win-64" ]] || rm "$PREFIX"/lib/libzimg.a
