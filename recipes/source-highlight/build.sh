#!/bin/bash

autoreconf -i
mkdir build
cd build
../configure \
      --prefix=$PREFIX \
      CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include" \
      LDFLAGS=-"${LDFLAGS} L${PREFIX}/lib"

make
make install
