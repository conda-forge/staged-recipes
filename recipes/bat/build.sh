#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# build statically linked binary with Rust
cargo build   --release
cargo install --root "$PREFIX" --path .

# strip debug symbols
strip "$PREFIX/bin/bat"