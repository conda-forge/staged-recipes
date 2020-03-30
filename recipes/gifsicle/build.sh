autoreconf -i
./configure --disable-gifview --prefix=${PREFIX}
make
make install
