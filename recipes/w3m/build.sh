#!/bin/bash

mkdir -p $PREFIX/bin
export LDFLAGS="-L$PREFIX/lib"
export CPPFLAGS="-I$PREFIX/include"
./configure --prefix=$PREFIX
make
make install
