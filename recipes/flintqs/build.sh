#!/bin/bash

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CXXFLAGS="-g -fomit-frame-pointer -O3 -Wno-sign-compare -Wno-write-strings $CXXFLAGS"

chmod +x configure

./configure \
    --prefix="$PREFIX" \
    --libdir="$PREFIX/lib"

make
make check
make install
