#!/bin/sh
export CFLAGS="$CFLAGS -I$PREFIX/include -L${PREFIX}/lib"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
make CC=${CC} CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" all
mv include/* ${PREFIX}/include/
mv lib/* ${PREFIX}/lib/
