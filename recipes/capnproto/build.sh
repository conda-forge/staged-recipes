#!/bin/bash

mkdir build
cd build

CMAKE_CXX_FLAGS="-fPIC"
if [ "$(uname)" = "Darwin" ]; then
    CMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS -stdlib=libc++"
fi

cmake \
    -DBUILD_TESTING=OFF \
    -DCMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS" \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    ../c++

make
make install
