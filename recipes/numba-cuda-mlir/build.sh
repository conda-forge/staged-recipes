#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail

cd "${SRC_DIR}/src"

PARALLEL="${PARALLEL:-${CPU_COUNT:-$(nproc)}}"
export PARALLEL
export PYTHON="${PREFIX}/bin/python"


export BUILD_ROOT="${SRC_DIR}/_llvm_build"
export LLVM_MODERN_INSTALL="${SRC_DIR}/llvm-modern-install"
export LLVM_MODERN_SRC="${SRC_DIR}/llvm-modern-src"

chmod +x ci/*.sh
sed -i '/sccache/d' ci/build-llvm-modern.sh

echo "=============================================================="
echo "Step 1/2: Modern LLVM/MLIR + Python bindings"
echo "=============================================================="
ci/build-llvm-modern.sh

echo "=============================================================="
echo "Step 2/2: numba_cuda_mlir wheel"
echo "=============================================================="

# CUDA headers come from the conda host env; FindCUDAToolkit.cmake honors
# $CUDAToolkit_ROOT for cuda.h.
export CUDAToolkit_ROOT="${PREFIX}"
export DLPACK_PATH="${PREFIX}"
export MLIR_DIR="${LLVM_MODERN_INSTALL}/lib/cmake/mlir"
# LIBLLVM7 intentionally unset: we don't bundle libLLVM-7.so. The legacy LLVM 7
# runtime is provided by the libllvm7.1 conda package (see symlink below).

"${PYTHON}" -m pip install . \
    --no-build-isolation \
    --no-deps \
    -vv

# numba-cuda-mlir's runtime loader looks for a bundled
# numba_cuda_mlir/lib/libLLVM-7.so. Point that at the conda libllvm7.1 library
SP="$("${PYTHON}" -c "import sysconfig; print(sysconfig.get_paths()['platlib'])")"
mkdir -p "${SP}/numba_cuda_mlir/lib"
# $SP/numba_cuda_mlir/lib -> up 4 -> $PREFIX/lib
ln -sf ../../../../libLLVM-7.1.so "${SP}/numba_cuda_mlir/lib/libLLVM-7.so"
