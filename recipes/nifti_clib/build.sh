#!/bin/sh
export CFLAGS="$CFLAGS -I$PREFIX/include -L${PREFIX}/lib"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
make CC=${CC} CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" all
cp include/* ${PREFIX}/include/
cp lib/* ${PREFIX}/lib/
