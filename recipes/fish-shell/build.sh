#!/bin/sh

autoconf
./configure --prefix=$PREFIX --includedir=$PREFIX/include/ncursesw:$PREFIX/include
make -j4
make install
