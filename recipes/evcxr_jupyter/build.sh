#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# build statically linked binary with Rust
cargo install --root "$PREFIX" --path ./evcxr_jupyter

# strip debug symbols
"$STRIP" "$PREFIX/bin/evcxr_jupyter"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
