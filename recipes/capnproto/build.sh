#!/bin/bash

mkdir build
cd build

CMAKE_CXX_FLAGS="-fPIC"
if [ "$(uname)" = "Darwin" ]; then
    # "-stdlib=libc++ -mmacosx-version-min=10.7" are required to enable C++11 features
    CMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS -stdlib=libc++"
    CMAKE_EXTRA_ARGS="-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7"
fi

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_TESTING=OFF \
    -DCMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS" \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    $CMAKE_EXTRA_ARGS \
    ../c++

cmake --build .
cmake --build . --target install
