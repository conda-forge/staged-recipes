#!/bin/bash

[[ -d build ]] || mkdir build
cd build/

# have to set CMAKE_INSTALL_LIBDIR otherwise it ends up under 'x86_64-linux-gnu'

cmake \
    -D CMAKE_INSTALL_PREFIX=$PREFIX \
    -D CMAKE_INSTALL_LIBDIR=$PREFIX/lib \
    ..

make
# No "make check" available
make install
