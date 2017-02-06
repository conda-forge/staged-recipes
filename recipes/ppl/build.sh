#!/bin/bash

export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH
export CFLAGS="-O2 -g -fPIC $CFLAGS"

chmod +x configure

./configure --prefix=$PREFIX \
            --with-gmp-include="$PREFIX/include" \
            --with-gmp-lib="$PREFIX/lib" \
            --enable-coefficients=mpz \
            --enable-interfaces=c,c++
make
make check
make install
