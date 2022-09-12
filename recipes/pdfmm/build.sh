#!/usr/bin/env bash

# CC=clang
# CXX=clang++

CXX_FLAGS="${CXX_FLAGS} -fmessage-length=0 -fstack-protector-all -Ofast -D_FORTIFY_SOURCE=2"
CXX_FLAGS="${CXX_FLAGS} -funwind-tables -fpic -fasynchronous-unwind-tables"

# configure cmake
rm -rf build
cmake -B build \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=17 \
  -DPDFMM_BUILD_STATIC=OFF \
  -DPDFMM_USE_VISIBILITY=ON \
  -DPDFMM_BUILD_LIB_ONLY=ON

# build
cmake --build build

# install
cmake --install build --prefix=${PREFIX}
