#!/bin/bash

set -xeuo pipefail

mkdir build
cd build

# The default ROCTX probe can silently link a system roctracer installation,
# which is not a dependency of this recipe.
cmake \
    -GNinja \
    ${CMAKE_ARGS} \
    -DGPU_TARGETS="${CONDA_FORGE_DEFAULT_ROCM_GPU_TARGETS}" \
    -DBUILD_CLIENTS_TESTS=OFF \
    -DBUILD_CLIENTS_BENCHMARKS=OFF \
    -DBUILD_CLIENTS_SAMPLES=OFF \
    -DBUILD_WITH_ROCTX=OFF \
    ..

cmake --build . -j${CPU_COUNT}
cmake --install .