#!/bin/bash

export CFLAGS="-I${PREFIX}/include ${CFLAGS}"
export LDFLAGS="-L${PREFIX}/lib ${LDFLAGS}"

./configure --prefix=${PREFIX} --enable-shared --without-guile
make
make install
cp src/ctl-math.h ${PREFIX}/include

rm $PREFIX/lib/libctlgeom.a
