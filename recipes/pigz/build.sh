#!/bin/bash

LDFLAGS="$LDFLAGS -L$PREFIX/lib"

make -j$CPU_COUNT LDFLAGS="$LDFLAGS"
make test

cp pigz unpigz $PREFIX/bin
