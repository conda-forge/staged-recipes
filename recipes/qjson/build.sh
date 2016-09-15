#!/bin/bash

[[ -d build ]] || mkdir build
cd build/

cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    ..

make
# No "make check" available
make install
