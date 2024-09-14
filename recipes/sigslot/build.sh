#!/bin/bash

set -euxo pipefail

cmake $SRC_DIR \
  ${CMAKE_ARGS} \
  -G Ninja \
  -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DSIGSLOT_COMPILE_EXAMPLES=OFF \
  -DSIGSLOT_COMPILE_TESTS=OFF \
  -DSIGSLOT_REDUCE_COMPILE_TIME=OFF \
  -DSIGSLOT_ENABLE_INSTALL=ON

cmake --build build --parallel

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  ctest --test-dir build --output-on-failure
fi

cmake --build build --parallel --target install
