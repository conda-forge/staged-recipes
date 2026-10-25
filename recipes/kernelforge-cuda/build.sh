#!/usr/bin/env bash
set -ex

if [[ "${cuda_compiler_version}" == "None" ]]; then
  echo "kernelforge-cuda requires a CUDA build (cuda_compiler_version != None)"
  exit 1
fi

export CUDA_HOME="${PREFIX}"
export CUDA_TOOLKIT_ROOT_DIR="${PREFIX}"

# Match the arch list conda-forge pytorch was built with (activation script).
# See: conda-forge/pytorch-cpu-feedstock recipe/activate.sh
if [[ -z "${CF_TORCH_CUDA_ARCH_LIST:-}" ]]; then
  echo "CF_TORCH_CUDA_ARCH_LIST is not set. Ensure the CUDA pytorch package is installed and activated."
  exit 1
fi
export TORCH_CUDA_ARCH_LIST="${CF_TORCH_CUDA_ARCH_LIST}"
echo "TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST}"

export CMAKE_ARGS="${CMAKE_ARGS} -DKF_WITH_CUDA=ON -DKF_CUDA_ONLY=ON -DKF_BLAS_VENDOR=OpenBLAS"

# Companion project lives under packaging/; CMake source dir is the monorepo root.
cd packaging/kernelforge-cuda
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
