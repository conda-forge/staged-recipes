#!/bin/bash

export CFLAGS="${PREFIX}/include ${CFLAGS}"
export LDFLAGS="${PREFIX}/lib ${LDFLAGS}"

./configure --prefix=${PREFIX} --enable-shared --without-guile
make
make install
cp src/ctl-math.h ${PREFIX}/include

rm $PREFIX/lib/libctlgeom.a
