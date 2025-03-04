#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# check licenses
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --locked --root "$PREFIX" --path cargo-insta --no-track

# strip debug symbols
"$STRIP" "$PREFIX/bin/cargo-insta"
