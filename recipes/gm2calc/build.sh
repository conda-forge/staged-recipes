#!/usr/bin/env bash

set -x
set -e
set -u
set -o pipefail

# Disable the Python interface as it will pip install cppyy into a venv at
# configure time.
cmake ${CMAKE_ARGS} \
    -GNinja \
    -DBUILD_SHARED_LIBS=ON \
    -DENABLE_EXAMPLES=OFF \
    -DENABLE_MATHEMATICA=OFF \
    -DENABLE_PYTHON=OFF \
    -DENABLE_TESTS=ON \
    -S "${SRC_DIR}" \
    -B build

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build

# Skip ctest when cross-compiling
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR:-}" != "" ]]; then
  ctest --test-dir build
fi
