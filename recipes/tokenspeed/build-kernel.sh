#!/bin/bash
set -euxo pipefail

export TOKENSPEED_KERNEL_BACKEND=cuda
# Use the release version rather than a date-dependent development version.
export TOKENSPEED_KERNEL_GIT_BRANCH=release/conda-forge
export TOKENSPEED_KERNEL_CONDA_BUILD=1
case "${target_platform}" in
    linux-64) export CUDA_HOME="${PREFIX}/targets/x86_64-linux" ;;
    linux-aarch64) export CUDA_HOME="${PREFIX}/targets/sbsa-linux" ;;
    *) exit 1 ;;
esac
export FLASHINFER_NVCC="$(command -v nvcc)"
export FLASHINFER_CUDA_ARCH_LIST="10.0a 10.3a"
export MAX_JOBS="${CPU_COUNT}"
"${PYTHON}" -m pip install ./tokenspeed-kernel/python -vv --no-deps --no-build-isolation
