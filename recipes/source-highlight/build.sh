#!/bin/bash

export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS}"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$PREFIX/lib"

autoreconf -i
mkdir build
cd build
../configure \
    --prefix=$PREFIX \
    --with-boost-libdir=${PREFIX}/lib
make
make install
