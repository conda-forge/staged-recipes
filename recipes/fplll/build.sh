#!/bin/bash

export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH
export CFLAGS="-O3 -g -fPIC $CFLAGS"

chmod +x configure

./configure --prefix=$PREFIX --libdir=$PREFIX/lib

make
make check
make install
