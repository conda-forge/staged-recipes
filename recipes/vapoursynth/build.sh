set -ex

./autogen.sh
./configure --prefix="$PREFIX" --enable-shared --disable-static
make -j${CPU_COUNT}
make install
