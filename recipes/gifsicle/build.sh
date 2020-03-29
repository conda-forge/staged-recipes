autoreconf -i
./configure --disable-gifview --prefix=${PREFIX}
make
pwd
ls
make check
make install
