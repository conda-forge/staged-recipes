#!/bin/bash

export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH
export CFLAGS="-O2 -g -fPIC $CFLAGS"; export CFLAGS

./configure --prefix=$PREFIX \
            --with-gmp=$PREFIX \
            --with-mpfr=$PREFIX
make
make check
make install
