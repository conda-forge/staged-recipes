libtoolize
autoreconf -fi
automake --add-missing --copy
./configure --prefix=$PREFIX --disable-gmp
make -j${CPU_COUNT}
make check
make install
