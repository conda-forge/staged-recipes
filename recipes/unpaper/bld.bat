
autoreconf -fi
./configure --prefix=$PREFIX
make -r
make install
