#!/bin/bash

mkdir build
cd build

CMAKE_CXX_FLAGS="-fPIC"
if [ "$(uname)" = "Darwin" ]; then
    # "-stdlib=libc++ -mmacosx-version-min=10.7" are required to enable C++11 features
    CMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS -stdlib=libc++ -mmacosx-version-min=10.7"
    EXTRA_CMAKE_ARGS="-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7"
    # Disable testing on OS X due to CMake config bugs fixed only in master:
    # https://github.com/sandstorm-io/capnproto/issues/322
    EXTRA_CMAKE_ARGS="$EXTRA_CMAKE_ARGS -DBUILD_TESTING=OFF"
fi

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS" \
    -DCMAKE_CXX_LINK_FLAGS="$CMAKE_CXX_LINK_FLAGS" \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    $EXTRA_CMAKE_ARGS \
    ../c++

cmake --build .

if [ "$(uname)" != "Darwin" ]; then
    cmake --build . --target check
fi

cmake --build . --target install
