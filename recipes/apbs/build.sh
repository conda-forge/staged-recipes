#!/bin/bash

set -e

cd apbs

# does not work in a separate ./build directory
cmake \
  -DBUILD_TOOLS:BOOL=OFF \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} .

make
make install
