#!/bin/bash

set -x

mkdir build
cd build
cmake ${CMAKE_ARGS} \
    -DUSE_INCLUDED_ZLIB=OFF -DUSE_INCLUDED_LIBZIP=OFF -DUSE_INCLUDED_SSL=OFF \
    -DCMAKE_BUILD_TYPE:String=Release \
    -DLIB3MF_TESTS=OFF \
    -GNinja \
    ..

ninja

ninja install