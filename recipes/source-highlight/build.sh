#!/bin/bash

export CXXFLAGS="${CXXFLAGS}"
export LDFLAGS="${LDFLAGS}"

autoreconf -i
mkdir build
cd build
../configure \
    --prefix=$PREFIX \
    --with-boost-libdir=${PREFIX}/lib
make
make install
