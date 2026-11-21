#!/usr/bin/env bash
set -ex

if [[ "${cuda_compiler_version}" == "None" ]]; then
  echo "kernelforge-cuda requires a CUDA build (cuda_compiler_version != None)"
  exit 1
fi

export CUDA_HOME="${PREFIX}"
export CUDA_TOOLKIT_ROOT_DIR="${PREFIX}"

# Prefer recipe/env TORCH_CUDA_ARCH_LIST (set in recipe.yaml). Fall back to a
# filtered CF_TORCH_CUDA_ARCH_LIST from pytorch if unset.
if [[ -z "${TORCH_CUDA_ARCH_LIST:-}" ]]; then
  if [[ -z "${CF_TORCH_CUDA_ARCH_LIST:-}" ]]; then
    echo "Neither TORCH_CUDA_ARCH_LIST nor CF_TORCH_CUDA_ARCH_LIST is set."
    exit 1
  fi
  # Drop Maxwell (5.x); double atomicAdd needs sm_60+.
  filtered=()
  IFS=';' read -ra arches <<< "${CF_TORCH_CUDA_ARCH_LIST}"
  for arch in "${arches[@]}"; do
    major="${arch%%.*}"
    major="${major%%+*}"
    if [[ "${major}" =~ ^[0-9]+$ ]] && (( major >= 6 )); then
      filtered+=("${arch}")
    fi
  done
  TORCH_CUDA_ARCH_LIST="$(IFS=';'; echo "${filtered[*]}")"
  export TORCH_CUDA_ARCH_LIST
fi
echo "TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST}"

# LTO + CUDA can OOM small CI agents; strip conda default -flto=auto if present.
export CFLAGS="${CFLAGS//-flto=auto/}"
export CXXFLAGS="${CXXFLAGS//-flto=auto/}"
export LDFLAGS="${LDFLAGS//-flto=auto/}"
export CMAKE_ARGS="${CMAKE_ARGS} -DKF_WITH_CUDA=ON -DKF_CUDA_ONLY=ON -DKF_BLAS_VENDOR=AUTO -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF"

cd packaging/kernelforge-cuda
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
