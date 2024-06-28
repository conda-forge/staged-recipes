#!/usr/bin/env bash

set -euxo pipefail

case "${target_platform}" in
  linux-aarch64)
    TARGET="-Dtarget=aarch64-linux"
    ;;

  linux-ppc64le)
    TARGET="-Dtarget=ppc64le-linux"
    ;;

  osx-arm64)
    TARGET="a-Dtarget=rm64-macos"
    ;;
esac

./configure
make -j"${CPU_COUNT}" && make check && make install prefix="${PREFIX}"

# Remove static lib
rm -f "${PREFIX}/lib/libsodium.la"
rm -f "${PREFIX}/lib/libsodium.a"

# ZIG requires glibc 2.28
# zig build "${TARGET:-}" -Doptimize=ReleaseFast