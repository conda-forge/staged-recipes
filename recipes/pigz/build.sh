#!/bin/bash

# Adopt a Unix-friendly path if we're on Windows (see bld.bat).
[ -n "$PATH_OVERRIDE" ] && export PATH="$PATH_OVERRIDE"

LDFLAGS="$LDFLAGS -L$PREFIX/lib"
CFLAGS="$CFLAGS -O3 -I$PREFIX/include"

make -j$CPU_COUNT LDFLAGS="$LDFLAGS" CFLAGS="$CFLAGS"
make test

cp pigz unpigz $PREFIX/bin
