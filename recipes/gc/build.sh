#!/bin/bash

mkdir -p $PREFIX/lib
export LDFLAGS="-L$PREFIX/lib"
export CPPFLAGS="-I$PREFIX/include"
export ATOMIC_OPS_CFLAGS="-I$PREFIX/include"
export ATOMIC_OPS_LIBS="-L$PREFIX/lib -latomic_ops"
./configure --prefix=$PREFIX --with-libatomic-ops=yes
make
make install
