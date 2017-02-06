#!/bin/bash

export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export CFLAGS="-O3 -g -fPIC -I$PREFIX/include $CFLAGS"
export CXXFLAGS="-O3 -g -fPIC -I$PREFIX/include $CXXFLAGS"

chmod +x configure

./configure --prefix=$PREFIX --libdir=$PREFIX/lib

make
make check
make install
