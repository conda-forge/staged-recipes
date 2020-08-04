#!/bin/sh

libtoolize
autoreconf -i
./configure --disable-examples --prefix=$PREFIX
make -j"${CPU_COUNT}"
make check
make install
