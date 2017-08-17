#!/bin/bash

mkdir -p $PREFIX/bin
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
./configure --prefix=$PREFIX
make
make install
