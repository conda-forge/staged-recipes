#!/bin/bash

set -ex

mkdir build
cd build

cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DLIBCORO_BUILD_TESTS=OFF \
    -DLIBCORO_BUILD_EXAMPLES=OFF \
    -DLIBCORO_EXTERNAL_DEPENDENCIES=ON \
    -DLIBCORO_BUILD_SHARED_LIBS=ON \
    ..

cmake --build . --config Release
cmake --install . --config Release
