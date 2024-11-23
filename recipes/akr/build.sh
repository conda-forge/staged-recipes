#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
export SODIUM_USE_PKG_CONFIG=1
cargo install --bins --no-track --locked --root ${PREFIX} --path crates/kr

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"
