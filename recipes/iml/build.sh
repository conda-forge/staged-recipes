#!/bin/bash

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-g -O3 $CFLAGS"

chmod +x configure
./configure \
        --prefix="$PREFIX" \
        --libdir="$PREFIX/lib" \
        --enable-shared \
        --with-default="$PREFIX" \
        --with-cblas="-lopenblas" \
        --with-cblas-include="$PREFIX/include"

make
make check
make install
