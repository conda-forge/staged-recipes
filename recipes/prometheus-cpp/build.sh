#!/bin/bash

set -ex

mkdir _build
pushd _build

# run cmake
cmake ${CMAKE_ARGS} .. \
    -GNinja \
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
if [ "${build_platform}" == "${target_platform}" ]; then
    ctest -V
fi 

# install the libraries and headers
cmake --install .