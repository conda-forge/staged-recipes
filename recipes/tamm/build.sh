#!/usr/bin/env bash

set -ex
if [[ ${cuda_compiler_version} != "None" ]]; then
  CUDA=ON
  #CMAKE_ARGS="-DCMAKE_CUDA_ARCHITECTURES=60;70;75;80;86;89;90;100;120 ${CMAKE_ARGS}"
  CMAKE_ARGS="-DCMAKE_CUDA_ARCHITECTURES=80 ${CMAKE_ARGS}"
  #CMAKE_BUILD_PARALLEL_LEVEL=1
else
  CUDA=OFF
fi

cmake \
  -B _build \
  -DALLOW_CONDA=ON \
  -DTAMM_ENABLE_CUDA=$CUDA \
  -DBUILD_SHARED_LIBS=ON \
  -DLINALG_VENDOR=ReferenceBLAS \
  -DLINALG_PREFIX=$PREFIX \
  -DBLAS_LIBRARIES=$PREFIX/lib/libblas.so \
  -DLAPACK_LIBRARIES=$PREFIX/lib/liblapack.so \
  -DBUILD_HPTT=OFF \
  -DHPTT_ROOT=$PREFIX \
  -DHDF5_ROOT=$PREFIX \
  ${CMAKE_ARGS}
cmake --build _build --parallel
cmake --install _build
