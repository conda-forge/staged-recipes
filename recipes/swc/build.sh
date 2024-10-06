#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

rm .cargo/config.toml
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
export RUSTC_BOOTSTRAP=1
cargo install --bins --no-track --locked --root ${PREFIX} --path crates/swc_cli_impl

# strip debug symbols
"$STRIP" "$PREFIX/bin/$PKG_NAME"
