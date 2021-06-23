#!/bin/sh
set -e -x # abort on error
./configure --prefix=$PREFIX --disable-devel --enable-optimizations
make
make check
make install-strip
mkdir -p $PREFIX/share/doc/spot/examples
cp tests/python/[a-z]*.ipynb $PREFIX/share/doc/spot/examples
