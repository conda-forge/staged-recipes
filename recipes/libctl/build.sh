#!/bin/bash

./configure --prefix=${PREFIX} --enable-shared --without-guile
make
make install
cp src/ctl-math.h ${PREFIX}/include

rm $PREFIX/lib/libctlgeom.a
