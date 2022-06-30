#!/usr/bin/env bash

set -ex

cmake \
    $CMAKE_ARGS \
    -B _build -G Ninja \
    -DSCINE_MARCH="" \
    -DBLA_VENDOR=Generic

cmake --build _build
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "0" ]]; then
  ctest --test-dir _build --output-on-failure
fi
cmake --install _build
