#!/bin/sh
make CFLAGS="-I$PREFIX/include -L${PREFIX}/lib" LDFLAGS=-L${PREFIX}/lib CC=${CC} all
mv include/* ${PREFIX}/include/
mv lib/* ${PREFIX}/lib/
