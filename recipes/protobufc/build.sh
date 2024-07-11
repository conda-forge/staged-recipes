#!/bin/bash

set -ex

cd build-cmake
mkdir build
cd build

#           cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=${{ matrix.build-type }} -DBUILD_TESTS=ON -DCMAKE_INSTALL_PREFIX=~/protobuf-c-bin -DBUILD_SHARED_LIBS=${{ matrix.shared-lib }} -DProtobuf_ROOT="~/protobuf-bin" -Dabsl_ROOT="~/abseil-bin" -Dutf8_range_ROOT="~/utf8_range-bin" ..

cmake ${CMAKE_ARGS} -G Ninja \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    ..

ninja -j${CPU_COUNT}
ninja install
