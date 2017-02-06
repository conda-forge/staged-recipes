#!/bin/bash

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-I$PREFIX/lib"
export CFLAGS="-O2 -g -fPIC $CFLAGS"

chmod +x configure

./configure --prefix=$PREFIX --libdir=$PREFIX --disable-sse2

make
make check
make install
