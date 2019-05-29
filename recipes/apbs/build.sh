#!/bin/bash

set -e

cd apbs

# does not work in a separate ./build directory
cmake \
  -DBUILD_TOOLS:BOOL=OFF \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} .

make
make install

# remove static libs
rm -f $PREFIX/lib/*.a

