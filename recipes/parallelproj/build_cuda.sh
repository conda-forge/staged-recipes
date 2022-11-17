#!/bin/bash
set -ex

mkdir build
cd build

cmake -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_CUDA_ARCHITECTURES=all \
    -DSKIP_DOCS=TRUE \
    -DSKIP_OPENMP_LIB=TRUE \
    ..

cmake --build . --target install --verbose 
