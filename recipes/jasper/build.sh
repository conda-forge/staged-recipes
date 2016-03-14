#!/bin/bash

export CFLAGS="-fPIC"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

sh configure --prefix=$PREFIX \
             --enable-shared \
             --disable-debug \
             --disable-dependency-tracking

make
make check
make install
