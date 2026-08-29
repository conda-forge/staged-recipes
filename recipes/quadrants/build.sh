#!/bin/bash

set -euxo pipefail

export LLVM_DIR="${PREFIX}/lib/cmake/llvm"
export CMAKE_GENERATOR=Ninja
export CMAKE_BUILD_PARALLEL_LEVEL="${CPU_COUNT}"
export SETUPTOOLS_SCM_PRETEND_VERSION="${PKG_VERSION}"

# Quadrants invokes Clang separately from the package compiler to emit the
# embedded LLVM runtime bitcode. Use the native build-prefix Clang for that
# executable step while linking the extension against target-prefix LLVM.
if [[ -x "${BUILD_PREFIX}/bin/clang++-22" ]]; then
  export CLANG_EXECUTABLE="${BUILD_PREFIX}/bin/clang++-22"
else
  export CLANG_EXECUTABLE="${BUILD_PREFIX}/bin/clang++"
fi

# target_platform is supplied by conda-build/rattler-build.
# shellcheck disable=SC2154
case "${target_platform}" in
  linux-64)
    backend_args="-DQD_WITH_CUDA=ON -DQD_WITH_AMDGPU=ON -DQD_WITH_VULKAN=ON -DQD_WITH_METAL=OFF"
    ;;
  linux-aarch64)
    backend_args="-DQD_WITH_CUDA=ON -DQD_WITH_AMDGPU=OFF -DQD_WITH_VULKAN=ON -DQD_WITH_METAL=OFF"
    ;;
  osx-*)
    # Upstream currently supports AMDGPU only on Linux and keeps Vulkan off
    # on macOS; Metal is the native macOS GPU backend.
    backend_args="-DQD_WITH_CUDA=OFF -DQD_WITH_AMDGPU=OFF -DQD_WITH_VULKAN=OFF -DQD_WITH_METAL=ON"
    ;;
  *)
    echo "Unsupported target platform: ${target_platform}" >&2
    exit 1
    ;;
esac

export CMAKE_ARGS="${CMAKE_ARGS:-} ${backend_args} -DQD_USE_SYSTEM_DEPS=ON -DQD_BUILD_TESTS=OFF -DSPIRV_WERROR=OFF -DCLANG_EXECUTABLE=${CLANG_EXECUTABLE}"

"${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation
