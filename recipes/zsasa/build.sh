#!/usr/bin/env bash
set -euo pipefail

: "${ZIG_TARGET:?recipe.yaml has no Zig target for ${target_platform}; add it to zig_target}"

# Keep both Zig caches inside the work directory. The zig activation script
# points the global cache at $HOME, which would let an earlier build's
# downloads satisfy this one.
export ZIG_GLOBAL_CACHE_DIR="${SRC_DIR}/.zig-global-cache"
export ZIG_LOCAL_CACHE_DIR="${SRC_DIR}/.zig-local-cache"

# Hand the dependencies to Zig without network access. `zig fetch <dir>`
# copies a local directory into ./zig-pkg/<package hash>, keeping only the
# files the package declares and computing the hash from them. `--system`
# below makes Zig read packages from that directory and nowhere else, and it
# looks them up by the hashes in build.zig.zon: a wrong or missing source
# stops the build instead of being fetched.
for dep in zig-deps/*/; do
    zig fetch "${dep}"
done

# -Dcpu=baseline: the lowest CPU of the target (x86-64-v1 on linux-64 and
# win-64, core2 on osx-64, generic armv8 on linux-aarch64, apple_m1 on
# osx-arm64), not the CPU of the build machine.
zig build \
    --system "${SRC_DIR}/zig-pkg" \
    --prefix "${PREFIX}" \
    -Doptimize=ReleaseFast \
    -Dtarget="${ZIG_TARGET}" \
    -Dcpu=baseline \
    -j"${CPU_COUNT:-1}" \
    --summary all
