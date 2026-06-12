#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail

cd "${SRC_DIR}/src"

PARALLEL="${PARALLEL:-${CPU_COUNT:-$(nproc)}}"
export PARALLEL
export PYTHON="${PREFIX}/bin/python"

# Two llvm versions
export BUILD_ROOT="${SRC_DIR}/_llvm_build"
export LLVM7_INSTALL="${SRC_DIR}/llvm7-install"
export LLVM_MODERN_INSTALL="${SRC_DIR}/llvm-modern-install"


export LLVM7_SRC="${SRC_DIR}/llvm7-src"
export LLVM_MODERN_SRC="${SRC_DIR}/llvm-modern-src"

chmod +x ci/*.sh


sed -i '/sccache/d' ci/build-llvm7.sh ci/build-llvm-modern.sh

echo "=============================================================="
echo "Step 1/3: LLVM 7.1.0 shared library (libLLVM-7.so)"
echo "=============================================================="
ci/build-llvm7.sh

echo "=============================================================="
echo "Step 2/3: Modern LLVM/MLIR + Python bindings"
echo "=============================================================="
ci/build-llvm-modern.sh

echo "=============================================================="
echo "Step 3/3: numba_cuda_mlir wheel (linked against both)"
echo "=============================================================="

# CUDA toolkit headers/libs come from the conda host env. The repo's bundled
# cmake/FindCUDAToolkit.cmake honors $CUDAToolkit_ROOT for cuda.h.
export CUDAToolkit_ROOT="${PREFIX}"
# Use conda's dlpack instead of CMake FetchContent (no network in build).
export DLPACK_PATH="${PREFIX}"
# Wire the two LLVM installs into the wheel build (same contract as the wheel CI).
export MLIR_DIR="${LLVM_MODERN_INSTALL}/lib/cmake/mlir"
export LIBLLVM7="${LLVM7_INSTALL}/lib/libLLVM-7.so"

"${PYTHON}" -m pip install . \
    --no-build-isolation \
    --no-deps \
    -vv
