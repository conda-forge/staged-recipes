#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# build statically linked binary with Rust
cargo install --features=all --root "$PREFIX" --path .

# strip debug symbols
"$STRIP" "$PREFIX/bin/sccache"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
