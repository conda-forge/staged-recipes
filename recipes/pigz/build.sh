#!/bin/bash

LDFLAGS="$LDFLAGS -L$PREFIX/lib"
CFLAGS="$CFLAGS -O3 -I$PREFIX/include"

make -j$CPU_COUNT LDFLAGS="$LDFLAGS" CFLAGS="$CFLAGS"
make test

cp pigz unpigz $PREFIX/bin
