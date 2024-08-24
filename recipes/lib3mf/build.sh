#!/bin/bash

mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE="Release" \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DUSE_INCLUDED_ZLIB=NO \
    -DUSE_INCLUDED_LIBZIP=NO \
    -DUSE_INCLUDED_SSL=NO \
    ${CMAKE_ARGS} \
    ..

cmake --build .
cmake --build . --target=install
