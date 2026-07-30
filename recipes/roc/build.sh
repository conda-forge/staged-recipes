#!/usr/bin/env bash

set -euxo pipefail

# Zig otherwise writes to a global cache under $HOME, which is not writable here.
export ZIG_GLOBAL_CACHE_DIR="${SRC_DIR}/.zig-global-cache"

# Zig does not consult the conda sysroot, so left alone it would link against
# whatever glibc the runner happens to have (2.34 on the alma9 image) while the
# package metadata promises the much older one conda-forge targets. Name it
# explicitly instead. roc's `target_is_native` check only compares os/arch/abi,
# so pinning the glibc version here still counts as a native build.
case "${target_platform}" in
  linux-64)      zig_target="x86_64-linux-gnu.${c_stdlib_version:-2.17}" ;;
  linux-aarch64) zig_target="aarch64-linux-gnu.${c_stdlib_version:-2.17}" ;;
  *)
    echo "unsupported target_platform: ${target_platform}" >&2
    exit 1
    ;;
esac

# --system resolves every dependency from the pre-populated package directory
# rather than fetching it, which keeps the build offline.
# -Dllvm-path replaces the prebuilt roc-bootstrap LLVM with the one from host.
zig build roc \
  -Doptimize=ReleaseFast \
  -Dtarget="${zig_target}" \
  -Dllvm-path="${PREFIX}" \
  --system "${SRC_DIR}/zig-pkg" \
  --summary all

install -d "${PREFIX}/bin"
install -m 755 zig-out/bin/roc "${PREFIX}/bin/roc"
