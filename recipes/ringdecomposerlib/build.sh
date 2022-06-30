#!/usr/bin/env bash

set -ex

cmake \
    $CMAKE_ARGS \
    -B _build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_MINIMAL_EXAMPLE=ON

cmake --build _build
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "0" ]]; then
  ctest --test-dir _build --output-on-failure
fi
cmake --install _build
