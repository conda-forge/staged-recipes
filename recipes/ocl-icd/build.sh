set -e

./configure --prefix=$PREFIX --enable-official-khronos-headers
make
make check
make install
