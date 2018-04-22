#!/bin/bash

ls ${PREFIX}
autoreconf -i
mkdir build
cd build
../configure \
      --prefix=$PREFIX \
      CXXFLAGS=-I${PREFIX}/include \
      LDFLAGS=-L${PREFIX}/lib \
      --with-boost-libdir=${PREFIX}/lib

make
make install
