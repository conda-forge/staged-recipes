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

# Double atomicAdd requires sm_60+. Prefer a lean arch list so staged-recipes
# Azure VMs do not OOM (pytorch defaults include 5.0..12.0 and blow RAM).
# Keep +PTX from the pytorch-provided list when present.
filtered=()
IFS=';' read -ra arches <<< "${CF_TORCH_CUDA_ARCH_LIST}"
for arch in "${arches[@]}"; do
  major="${arch%%.*}"
  major="${major%%+*}"
  # Match PyPI companion wheels: 7.5+ (skip 6.0/7.0 to cut compile/RAM).
  if [[ "${major}" =~ ^[0-9]+$ ]] && (( major >= 7 )); then
    # Drop plain 7.0; keep 7.5+.
    if [[ "${arch}" == 7.0 || "${arch}" == 7.0+PTX ]]; then
      continue
    fi
    filtered+=("${arch}")
  fi
done
if [[ ${#filtered[@]} -eq 0 ]]; then
  echo "No CUDA architectures >= 7.5 in CF_TORCH_CUDA_ARCH_LIST=${CF_TORCH_CUDA_ARCH_LIST}"
  exit 1
fi
export TORCH_CUDA_ARCH_LIST
TORCH_CUDA_ARCH_LIST="$(IFS=';'; echo "${filtered[*]}")"
echo "TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST} (filtered from ${CF_TORCH_CUDA_ARCH_LIST})"

# LTO + many CUDA arches OOMs Azure staged-recipes agents (~97% RAM observed).
export CFLAGS="${CFLAGS//-flto=auto/}"
export CXXFLAGS="${CXXFLAGS//-flto=auto/}"
export LDFLAGS="${LDFLAGS//-flto=auto/}"
export CMAKE_ARGS="${CMAKE_ARGS} -DKF_WITH_CUDA=ON -DKF_CUDA_ONLY=ON -DKF_BLAS_VENDOR=AUTO -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF"

cd packaging/kernelforge-cuda
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
