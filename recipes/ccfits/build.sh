#!/bin/bash

# cd CCfits

CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

mkdir build
cd build

cmake -DCMAKE_PREFIX_PATH=${PREFIX} -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} -DBUILD_SHARED_LIBS=on ..

make
make install

# Remove the cookbook binary
rm -rf $PREFIX/bin/cookbook
