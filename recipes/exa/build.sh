#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# build statically linked binary with Rust
cargo install --locked --root "$PREFIX" --path .

# strip debug symbols
strip "$PREFIX/bin/exa"
