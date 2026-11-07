#!/usr/bin/env bash
set -euxo pipefail

# Zig cross-compiles: build for the package's platform, not the build
# machine's (conda-forge builds osx-arm64 and linux-aarch64 on x86_64)
case "${target_platform}" in
    linux-64) target=x86_64-linux ;;
    linux-aarch64) target=aarch64-linux ;;
    linux-ppc64le) target=powerpc64le-linux ;;
    osx-64) target="x86_64-macos.${MACOSX_DEPLOYMENT_TARGET:-10.13}" ;;
    osx-arm64) target="aarch64-macos.${MACOSX_DEPLOYMENT_TARGET:-11.0}" ;;
    *) echo "unsupported platform ${target_platform}" >&2; exit 1 ;;
esac

export ZIG_GLOBAL_CACHE_DIR="${SRC_DIR}/.zig-global-cache"
export ZIG_LOCAL_CACHE_DIR="${SRC_DIR}/.zig-cache"
zig build bin -Dtarget="${target}" -Doptimize=ReleaseSafe --prefix "${PREFIX}"

# Installed next to the binary, it makes zfls report a release candidate
# version; a released zfls reports the plain one
rm "${PREFIX}/bin/zfls.prerelease"
