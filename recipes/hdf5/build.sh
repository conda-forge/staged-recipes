#!/bin/bash

./configure --prefix=$PREFIX \
    --enable-linux-lfs --with-zlib \
    --with-pthread=yes  --enable-cxx --with-default-plugindir=$PREFIX/lib/hdf5/plugin \
    --disable-silent-rules  # To make Travis happy with the level of activity.

make
make check
make install

rm -rf $PREFIX/share/hdf5_examples
