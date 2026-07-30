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

# Note the requirements: this deliberately does not pull in conda's C/C++
# compilers. Zig ships a complete toolchain and roc uses nothing from GCC, and
# their presence actively breaks the build -- mid-build roc compiles and runs a
# host tool (builtin_compiler) for the *native* target, which -Dtarget does not
# cover. Zig then resolves that one against the conda sysroot's glibc 2.17 while
# targeting the running 2.34, and the two disagree: either an unresolvable
# absolute path in 2.17's `libpthread.so` ld script, or undefined getrandom /
# copy_file_range / statx. Without the sysroot in view, Zig uses its own glibc
# for the host tool and the pin above for everything we ship.
#
# --system resolves every dependency from the pre-populated package directory
# rather than fetching it, which keeps the build offline. That directory also
# holds the roc-bootstrap LLVM, so no -Dllvm-path is needed: the default path
# picks it up as the lazy dependency it already expects.
zig build roc \
  -Doptimize=ReleaseFast \
  -Dtarget="${zig_target}" \
  --system "${SRC_DIR}/zig-pkg" \
  --summary all

install -d "${PREFIX}/bin"
install -m 755 zig-out/bin/roc "${PREFIX}/bin/roc"
