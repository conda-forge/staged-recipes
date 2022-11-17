#!/bin/bash
set -ex

mkdir build
cd build

cmake -G Ninja \
    -DALSO \
    -DPLEASE \
    -DUSE \
    -DLINEBREAKS \
    -DFOR \
    -DREADABILITY \
    ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DSKIP_DOCS=TRUE \
    -DSKIP_CUDA_LIB=TRUE \
    ..

cmake --build . --target install --verbose 
