#!/bin/bash

./autogen.sh

./configure \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --includedir=${PREFIX}/include \
    --with-geosconfig=$PREFIX/bin/geos-config

make
make check
make install

# remove the static library
rm -f ${PREFIX}/lib/librttopo.a
