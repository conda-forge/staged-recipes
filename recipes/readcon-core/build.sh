#!/bin/bash
set -euo pipefail

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo_args=(auditable cinstall --locked --prefix "$PREFIX" --libdir "$PREFIX/lib" --library-type cdylib)
if [ -n "${CARGO_BUILD_TARGET:-}" ]; then
    cargo_args+=(--target "${CARGO_BUILD_TARGET}")
fi
cargo "${cargo_args[@]}"

# Keep the flat public include layout and the C++ helper header shipped upstream.
install -d "$PREFIX/include"
install -m 644 include/readcon-core.h "$PREFIX/include/"
install -m 644 include/readcon-core.hpp "$PREFIX/include/"
