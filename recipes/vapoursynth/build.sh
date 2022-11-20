set -ex

./autogen.sh
./configure --prefix="$PREFIX" --enable-shared
make
