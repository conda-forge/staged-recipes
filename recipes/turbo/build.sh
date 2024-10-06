#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export RUSTC_BOOTSTRAP=1
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --bins --no-track --locked --root ${PREFIX} --path crates/turborepo

# strip debug symbols
"$STRIP" "$PREFIX/bin/turbo"
