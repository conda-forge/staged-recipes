#!/bin/bash

set -ex

export CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_CXX_STANDARD=11"

mkdir -p build-cpp
pushd build-cpp

cmake ${CMAKE_ARGS} ..  \
      -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DBUILD_TESTING=OFF \
      -DWITH_API_ONLY=ON \
      -DWITH_EXAMPLES=OFF

ninja install
popd
