#!/bin/sh

./configure --prefix=$PREFIX --with-pic

make -j$CPU_COUNT
make install
