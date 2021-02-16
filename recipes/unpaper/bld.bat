
autoreconf -fi
./configure --prefix=$PREFIX CFLAGS="-march=x86-64 -mtune=generic -O2 -pipe -flto ${CFLAGS}"
make -r
make install
