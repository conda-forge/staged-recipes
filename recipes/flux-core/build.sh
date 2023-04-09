#!/bin/bash
export CPPFLAGS="-D_GNU_SOURCE -D_FORTIFY_SOURCE=2 -O2 -isystem $PREFIX/include"
./configure --prefix=${PREFIX}
make
make check 
make install
