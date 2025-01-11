#!/bin/bash

set -exo pipefail

cmake \
  $SRC_DIR \
  ${CMAKE_ARGS} \
  -G Ninja \
  -B build \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DWITH_CUDA_BACKEND=OFF \
  -DWITH_OPENCL_BACKEND=OFF \
  -DWITH_ROCM_BACKEND=OFF

cmake --build build --parallel

cmake --install build --strip
