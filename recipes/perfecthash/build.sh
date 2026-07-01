#!/usr/bin/env bash
set -euo pipefail

profile="${PERFECTHASH_BUILD_PROFILE:-full}"
version_override="${PERFECTHASH_VERSION_OVERRIDE:-${PKG_VERSION:-${PERFECTHASH_CONDA_VERSION:-0.0.0}}}"

case "$profile" in
  full|online-rawdog-jit|online-rawdog-and-llvm-jit|online-llvm-jit)
    ;;
  *)
    echo "error: invalid PERFECTHASH_BUILD_PROFILE '$profile'" >&2
    exit 1
    ;;
esac

build_dir="build-conda-${profile}"

echo "==> Building conda output for profile: ${profile}"
echo "==> Using version override: ${version_override}"

cmake_args=(
  -S .
  -B "${build_dir}"
  -G Ninja
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_INSTALL_PREFIX="$PREFIX"
  -DPERFECTHASH_BUILD_PROFILE="$profile"
  -DPERFECTHASH_VERSION_OVERRIDE="${version_override}"
  -DPERFECTHASH_ENABLE_TESTS=OFF
  -DBUILD_TESTING=OFF
)

if command -v nasm >/dev/null 2>&1; then
  nasm_path="$(command -v nasm)"
  echo "==> Using NASM from PATH: ${nasm_path}"
  cmake_args+=("-DCMAKE_ASM_NASM_COMPILER=${nasm_path}")
elif [ -n "${BUILD_PREFIX:-}" ] && [ -x "${BUILD_PREFIX}/bin/nasm" ]; then
  echo "==> Using NASM from BUILD_PREFIX: ${BUILD_PREFIX}/bin/nasm"
  cmake_args+=("-DCMAKE_ASM_NASM_COMPILER=${BUILD_PREFIX}/bin/nasm")
fi

cmake "${cmake_args[@]}"

cmake --build "${build_dir}" --parallel
cmake --install "${build_dir}"
