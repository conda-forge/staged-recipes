#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -G Ninja \
    -D CMAKE_BUILD_TYPE:STRING=Release \
    -D BUILD_SHARED_LIBS:BOOL=TRUE \
    -D CMAKE_INSTALL_PREFIX="${PREFIX}" \
    -D DCMTK_ENABLE_PRIVATE_TAGS:BOOL=TRUE \
    ..

cmake --build . --target install --parallel

