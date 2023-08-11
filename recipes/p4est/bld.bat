.\configure CFLAGS="-O2 -Wall -Wno-unused-parameter"
make install
make -j check V=0
