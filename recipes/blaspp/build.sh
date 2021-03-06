#!/bin/bash

cmake -S . -B build             \
    -DCMAKE_INSTALL_LIBDIR=lib        \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}  \
    -DCMAKE_BUILD_TYPE=Release  \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DBUILD_SHARED_LIBS=ON      \
    -Dbuild_tests=OFF           \
    -Duse_cmake_find_blas=ON    \
    -Duse_openmp=ON             \
    -Duse_cuda=OFF

cmake --build build --parallel ${CPU_COUNT}

cmake --build build --target install
