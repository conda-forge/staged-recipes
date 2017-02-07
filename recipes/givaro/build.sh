#!/bin/bash

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib -stdlib=libc++"
export CFLAGS="-fPIC -O2 $CFLAGS"
export CXXFLAGS="-fPIC -O2 $CXXFLAGS"

chmod +x configure

./configure --prefix=$PREFIX --libdir=$PREFIX/lib --disable-simd

make
make check
make install
