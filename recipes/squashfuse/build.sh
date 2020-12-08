./configure --prefix=$PREFIX --with-fuse=$PREFIX --with-fuse-lib=$PREFIX/lib
make -j${CPU_COUNT}
make install
