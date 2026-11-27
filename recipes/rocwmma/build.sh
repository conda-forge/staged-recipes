#!/bin/bash

set -xeuo pipefail

# Use CXX from the conda-forge Clang activation.
# CMAKE_ARGS contains separate command-line options.
# shellcheck disable=SC2086
cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DFETCHCONTENT_FULLY_DISCONNECTED=ON \
    -DGPU_TARGETS="${CONDA_FORGE_DEFAULT_ROCM_GPU_TARGETS}" \
    -DROCWMMA_BUILD_TESTS=OFF \
    -DROCWMMA_BUILD_SAMPLES=OFF

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
