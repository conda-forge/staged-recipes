#!/bin/sh

autoconf
./configure --prefix=$PREFIX --includedir=$CONDA_PREFIX/include/ncursesw
make -j4
make install
