#!/bin/bash

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$PREFIX/lib"
export CFLAGS="-O2 -g -fPIC $CFLAGS"

chmod +x configure

./configure --prefix=$PREFIX --libdir=$PREFIX/lib --disable-sse2

make
make check
make install
