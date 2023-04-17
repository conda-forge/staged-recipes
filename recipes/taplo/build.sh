#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# build statically linked binary with Rust
cargo install --locked \
    --root "$PREFIX" \
    --path crates/taplo-cli \
    --features lsp,rustls-tls

# strip debug symbols
"$STRIP" "$PREFIX/bin/taplo"

cargo-bundle-licenses \
    --format yaml \
    --output "${SRC_DIR}/THIRDPARTY.yml"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
