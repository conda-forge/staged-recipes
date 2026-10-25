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

# Double atomicAdd requires sm_60+. Drop Maxwell (5.x) from pytorch's default list.
filtered=()
IFS=';' read -ra arches <<< "${CF_TORCH_CUDA_ARCH_LIST}"
for arch in "${arches[@]}"; do
  major="${arch%%.*}"
  major="${major%%+*}"
  if [[ "${major}" =~ ^[0-9]+$ ]] && (( major >= 6 )); then
    filtered+=("${arch}")
  fi
done
if [[ ${#filtered[@]} -eq 0 ]]; then
  echo "No CUDA architectures >= 6.0 in CF_TORCH_CUDA_ARCH_LIST=${CF_TORCH_CUDA_ARCH_LIST}"
  exit 1
fi
export TORCH_CUDA_ARCH_LIST
TORCH_CUDA_ARCH_LIST="$(IFS=';'; echo "${filtered[*]}")"
echo "TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST} (filtered from ${CF_TORCH_CUDA_ARCH_LIST})"

export CMAKE_ARGS="${CMAKE_ARGS} -DKF_WITH_CUDA=ON -DKF_CUDA_ONLY=ON -DKF_BLAS_VENDOR=AUTO"

cd packaging/kernelforge-cuda
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
