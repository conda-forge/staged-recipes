#!/usr/bin/env bash

set -ex

cmake \
  -B _build \
  -G Ninja \
  -DBUILD_SHARED_LIBS=ON \
  -DENABLE_BLAS=ON \
  -DLINALG_VENDOR=ReferenceBLAS \
  -DLINALG_PREFIX=$PREFIX \
  -DBLAS_LIBRARIES=$PREFIX/lib/libblas.so \
  -DLAPACK_LIBRARIES=$PREFIX/lib/liblapack.so \
  ${CMAKE_ARGS}
cmake --build _build
cmake --install _build
