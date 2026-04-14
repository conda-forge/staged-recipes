#!/usr/bin/env bash
set -euxo pipefail

export LLVM_SYS_180_PREFIX="${PREFIX}"

# The patched Config::new() resolves INKO_STD/INKO_RT from the environment,
# then from <exe_dir>/../lib/inko/{std,runtime}, and only falls back to the
# compile-time env!() value as a last resort. We still have to satisfy the
# env!() macro at build time, but we deliberately bake placeholder-free
# literal paths so rattler-build's prefix rewriter has nothing to touch in
# the resulting binary. These fallback paths should never be reached at
# runtime for a conda-installed inko.
INKO_STD="/nonexistent/inko/std" \
INKO_RT="/nonexistent/inko/runtime" \
  cargo auditable build --release --locked

TARGET_SUBDIR="target/${CARGO_BUILD_TARGET:-}/release"
if [[ ! -f "${TARGET_SUBDIR}/inko" ]]; then
  TARGET_SUBDIR="target/release"
fi

INSTALL_STD="${PREFIX}/lib/inko/std"
INSTALL_RT="${PREFIX}/lib/inko/runtime"

mkdir -p "${PREFIX}/bin" "${INSTALL_STD}" "${INSTALL_RT}"
install -m755 "${TARGET_SUBDIR}/inko" "${PREFIX}/bin/inko"
install -m644 "${TARGET_SUBDIR}/libinko.a" "${INSTALL_RT}/libinko.a"
cp -r std/src/. "${INSTALL_STD}/"

cargo-bundle-licenses --format yaml --output ./THIRDPARTY.yml
