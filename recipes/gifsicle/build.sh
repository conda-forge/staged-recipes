autoreconf -i
./configure --disable-gifview --prefix=${PREFIX}
make check
make install
