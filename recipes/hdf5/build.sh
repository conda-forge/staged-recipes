#!/bin/bash

./configure --prefix=$PREFIX \
    --enable-linux-lfs --with-zlib \
    --with-pthread=yes  --enable-cxx --with-default-plugindir=$PREFIX/lib/hdf5/plugin

make
make check
make install

rm -rf $PREFIX/share/hdf5_examples
