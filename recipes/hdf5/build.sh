#!/bin/bash

if [ `uname -m` == ppc64le ]; then
    B="--build=ppc64le-linux"
fi

./configure $B --prefix=$PREFIX \
    --enable-linux-lfs --with-zlib \
    --with-pthread=yes  --enable-cxx --with-default-plugindir=$PREFIX/lib/hdf5/plugin

make
make install

rm -rf $PREFIX/share/hdf5_examples
