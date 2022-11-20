set -ex

./autogen.sh
./configure --prefix="$PREFIX" --enable-shared --disable-static
[[ "$target_platform" == "win-64" ]] && patch_libtool
make -j${CPU_COUNT}
make install
