#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit


cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --root "$PREFIX" --path . --no-default-features --verbose

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
