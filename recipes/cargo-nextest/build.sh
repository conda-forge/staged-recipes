#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# build statically linked binary with Rust
cargo install --locked --root "$PREFIX" --path cargo-nextest

# strip debug symbols
"$STRIP" "$PREFIX/bin/cargo-nextest"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
