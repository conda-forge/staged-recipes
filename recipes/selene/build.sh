#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# check licenses
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --no-target --locked --root ${PREFIX} --path selene

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"
