#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail

# The package working tree lives under src/ (see meta.yaml `source.folder`).
cd "${SRC_DIR}/src"

PARALLEL="${PARALLEL:-${CPU_COUNT:-$(nproc)}}"
export PARALLEL
export PYTHON="${PREFIX}/bin/python"

# --- sccache: use a local on-disk cache, never the GHA/S3 backend ----------
# The ci/build-llvm-*.sh scripts hard-require sccache as a compiler launcher.
# Strip any inherited GHA backend config so it falls back to local disk.
unset SCCACHE_GHA_ENABLED ACTIONS_RUNTIME_TOKEN ACTIONS_RUNTIME_URL \
      ACTIONS_RESULTS_URL ACTIONS_CACHE_URL ACTIONS_CACHE_SERVICE_V2 \
      SCCACHE_BUCKET SCCACHE_REGION SCCACHE_S3_USE_SSL 2>/dev/null || true
export SCCACHE_DIR="${SCCACHE_DIR:-${SRC_DIR}/.sccache}"
mkdir -p "${SCCACHE_DIR}"

# --- where the two LLVM trees get installed --------------------------------
export BUILD_ROOT="${SRC_DIR}/_llvm_build"
export LLVM7_INSTALL="${SRC_DIR}/llvm7-install"
export LLVM_MODERN_INSTALL="${SRC_DIR}/llvm-modern-install"

# Point the build scripts at the pre-extracted, sha256-pinned LLVM sources
# declared in meta.yaml. ci/build-llvm7.sh and ci/build-llvm-modern.sh both
# skip their `git clone` when "${LLVM_*_SRC}/llvm" already exists, so the build
# does zero network access (required on conda-forge).
export LLVM7_SRC="${SRC_DIR}/llvm7-src"
export LLVM_MODERN_SRC="${SRC_DIR}/llvm-modern-src"

chmod +x ci/*.sh

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
export CMAKE_C_COMPILER_LAUNCHER="$(command -v sccache)"
export CMAKE_CXX_COMPILER_LAUNCHER="$(command -v sccache)"
# Do NOT set CMAKE_GENERATOR here: setup.py's build_ext invokes `make` directly,
# so cmake must use the default "Unix Makefiles" generator (and `make` must be
# in the build env -- see the recipe's build requirements).

"${PYTHON}" -m pip install . \
    --no-build-isolation \
    --no-deps \
    -vv

sccache --show-stats || true
