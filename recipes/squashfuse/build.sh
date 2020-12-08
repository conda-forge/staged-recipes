./configure --prefix=$PREFIX --with-fuse=$PREFIX --with-fuse-lib=$PREFIX/lib --enable-shared --disable-static
make -j${CPU_COUNT}
make check
make install
