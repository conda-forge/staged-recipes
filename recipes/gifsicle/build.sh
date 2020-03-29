autoreconf -i
./configure --disable-gifview --prefix=${PREFIX}
make
make check
make install
