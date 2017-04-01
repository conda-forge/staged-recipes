#!/bin/bash

env | sort

export LIBS="-L$PREFIX/lib"
export CPPFLAGS="-I$PREFIX/include"
./configure --prefix=$PREFIX --disable-libwrap
make -j$CPU_COUNT
make install
