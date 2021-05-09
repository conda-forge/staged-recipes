#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# build statically linked binary with Rust
cargo install --locked --features all --root "$PREFIX" --path .

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
