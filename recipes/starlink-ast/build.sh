#!/bin/bash
export CFLAGS="$CFLAGS -g -O3"

./configure --prefix=$PREFIX --libdir=$PREFIX/lib --without-fortran --without-stardocs --without-pthreads
make
make check
make install
