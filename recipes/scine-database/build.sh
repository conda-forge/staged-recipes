#!/usr/bin/env bash

set -ex

cmake \
    $CMAKE_ARGS \
    -B _build -G Ninja \
    -DSCINE_MARCH="" \
    -DSCINE_USE_INTEL_MKL=OFF \
    -DSCINE_USE_STATIC_LINALG=OFF \
    -DSCINE_USE_LAPACKE=OFF \
    -DSCINE_USE_BLAS=ON \
    -DBLA_VENDOR=Generic

cmake --build _build
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "0" ]]; then
  mkdir $PWD/_db
  mongod --dbpath $PWD/_db &
  sleep 2
  ctest --test-dir _build --output-on-failure
  pkill mongod
fi
cmake --install _build
