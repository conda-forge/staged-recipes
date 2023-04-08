#!/bin/bash
export CPPFLAGS="-DNDEBUG -D_FORTIFY_SOURCE=2 -O2 -isystem $PREFIX/include"
./configure --prefix=${PREFIX}
make
make check 
make install
