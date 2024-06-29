#!/usr/bin/env bash

set -euxo pipefail

if [[ "${CONDA_CROSS_COMPILATION:-0}" == "1" ]]; then
  case "${target_platform}" in
    linux-aarch64)
      HOST="--host=aarch64-linux-gnu"
      ;;

    linux-ppc64le)
      HOST="--host=ppc64le-linux-gnu"
      ;;

    win-64)
      HOST="--host=x86_64-w64-mingw32"
      ;;

    osx-arm64)
      HOST="--host=arm64-macos-gnu"
      ;;
  esac
fi

cd "${SRC_DIR}"/build-release
  ./configure "${HOST:-}" --prefix="${PREFIX}"
  make -j"${CPU_COUNT}"

  if [[ "${CONDA_CROSS_COMPILATION:-0}" == "0" ]]; then
    make check
  fi

  make install
cd ..

# Remove static lib
rm -f "${PREFIX}/lib/libsodium.la"
rm -f "${PREFIX}/lib/libsodium.a"

cp build-release/LICENSE "${RECIPE_DIR}"

# ZIG requires glibc 2.28
# zig build "${TARGET:-}" -Doptimize=ReleaseFast