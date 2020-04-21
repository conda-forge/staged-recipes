set -ex

./configure \
    --prefix=${PREFIX} \
    --with-zlib=${PREFIX}

make
make install
