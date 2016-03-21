#!/bin/bash

export LDFLAGS="-L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
./configure --prefix=$PREFIX --with-gmp

make
make check
make install
