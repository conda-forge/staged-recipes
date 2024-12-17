./configure --prefix=$PREFIX --with-libgsasl
make -j${CPU_COUNT}
make check
make install
