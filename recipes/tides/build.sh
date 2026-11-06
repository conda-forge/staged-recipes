#!/bin/bash

export CFLAGS="$CFLAGS -I$PREFIX/include"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

./configure --prefix=$PREFIX \
            --with-gmp=$PREFIX \
            --with-mpfr=$PREFIX

make -j${CPU_COUNT}
make install
