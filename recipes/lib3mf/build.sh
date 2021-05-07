#!/bin/bash

set -x

mkdir build
cd build
cmake ${CMAKE_ARGS} \ 
    -DCMAKE_BUILD_TYPE:String=Release \
    -DLIB3MF_TESTS=OFF \
    -GNinja \
    ..

ninja
ninja install