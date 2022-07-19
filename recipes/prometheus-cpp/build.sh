#!/bin/bash

set -ex

mkdir _build
pushd _build

# run cmake
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DBUILD_SHARED_LIBS=ON \
    -DENABLE_PUSH=ON \
    -DENABLE_COMPRESSION=ON

# build
cmake --build . --parallel 4

# run tests
ctest -V

# install the libraries and headers
cmake --install .