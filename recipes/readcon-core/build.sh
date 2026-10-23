#!/bin/bash
set -euo pipefail

# Match conda-forge rust example / lol-html: smaller, optimized release artifacts.
export CARGO_PROFILE_RELEASE_STRIP="${CARGO_PROFILE_RELEASE_STRIP:-symbols}"
export CARGO_PROFILE_RELEASE_LTO="${CARGO_PROFILE_RELEASE_LTO:-fat}"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo_args=(auditable cinstall --locked --prefix "$PREFIX" --libdir "$PREFIX/lib" --library-type cdylib)
if [ -n "${CARGO_BUILD_TARGET:-}" ]; then
    cargo_args+=(--target "${CARGO_BUILD_TARGET}")
fi
cargo "${cargo_args[@]}"
