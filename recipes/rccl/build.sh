#!/bin/bash
set -euxo pipefail

# Use packaged fmt and rocm-cmake rather than downloading dependencies.
# RCCL's toolchain reads CXX from the conda-forge Clang activation.
# CMAKE_ARGS contains separate command-line options.
# shellcheck disable=SC2086
cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DROCM_PATH="${PREFIX}" \
    -DROCMCORE_PATH="${PREFIX}" \
    -DGPU_TARGETS="${CONDA_FORGE_DEFAULT_ROCM_GPU_TARGETS}" \
    -DAMDGPU_TARGETS="${CONDA_FORGE_DEFAULT_ROCM_GPU_TARGETS}" \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTS=OFF \
    -DBUILD_BFD=OFF \
    -DRCCL_ROCPROFILER_REGISTER=OFF \
    -DENABLE_MSCCLPP=OFF \
    -DROCTX=OFF \
    -DFETCHCONTENT_FULLY_DISCONNECTED=ON \
    -DCMAKE_REQUIRE_FIND_PACKAGE_fmt=ON \
    -DCMAKE_REQUIRE_FIND_PACKAGE_ROCM=ON

# HIP compilation uses substantial memory for each GPU architecture.
cmake --build build --parallel "$(( CPU_COUNT > 4 ? 4 : CPU_COUNT ))"
cmake --install build
