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

zig build "${TARGET:-}" -Doptimize=ReleaseFast