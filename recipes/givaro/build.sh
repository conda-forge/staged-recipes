#!/bin/bash

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-fPIC -O2 $CFLAGS"
export CXXFLAGS="-fPIC -O2 $CXXFLAGS"

chmod +x configure

./configure --prefix=$PREFIX --libdir=$PREFIX/lib --disable-simd

make
make check
make install
