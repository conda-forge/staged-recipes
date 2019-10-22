
./configure \
    --prefix=$PREFIX \
    --enable-shared=yes

make -j${CPU_COUNT} VERBOSE=1
make -j${CPU_COUNT} VERBOSE=1 shlib
make install
