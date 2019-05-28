#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# build statically linked binary with Rust
cargo build   --features pcre2 --release
cargo install --features pcre2 --root "$PREFIX" --path .

# strip debug symbols
strip "$PREFIX/bin/rg"
