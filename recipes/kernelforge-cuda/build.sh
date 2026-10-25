#!/usr/bin/env bash
set -ex

if [[ "${cuda_compiler_version}" == "None" ]]; then
  echo "kernelforge-cuda requires a CUDA build (cuda_compiler_version != None)"
  exit 1
fi

export CUDA_HOME="${PREFIX}"
export CUDA_TOOLKIT_ROOT_DIR="${PREFIX}"

if [[ -z "${CF_TORCH_CUDA_ARCH_LIST:-}" ]]; then
  echo "CF_TORCH_CUDA_ARCH_LIST is not set. Ensure the CUDA pytorch package is installed and activated."
  exit 1
fi

# Lean arch list for staged-recipes Azure RAM limits. Feedstock can widen later.
# Double atomicAdd needs sm_60+; keep 8.0/8.6/9.0 + PTX from the pytorch list.
export TORCH_CUDA_ARCH_LIST="8.0;8.6;9.0+PTX"
echo "TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST} (lean staged-recipes set; CF was ${CF_TORCH_CUDA_ARCH_LIST})"

# Serialise the build: parallel nvcc fatbins OOMs ~8GB Azure agents.
export CMAKE_BUILD_PARALLEL_LEVEL=1
export MAX_JOBS=1

# LTO + CUDA OOMs Azure staged-recipes agents (~97% RAM observed).
export CFLAGS="${CFLAGS//-flto=auto/}"
export CXXFLAGS="${CXXFLAGS//-flto=auto/}"
export LDFLAGS="${LDFLAGS//-flto=auto/}"
export CMAKE_ARGS="${CMAKE_ARGS} -DKF_WITH_CUDA=ON -DKF_CUDA_ONLY=ON -DKF_BLAS_VENDOR=AUTO -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF"

cd packaging/kernelforge-cuda
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
