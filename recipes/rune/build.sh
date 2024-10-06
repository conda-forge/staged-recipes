#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --bins --no-track --locked --root ${PREFIX} --path crates/rune-cli
cargo install --bins --no-track --locked --root ${PREFIX} --path crates/rune-languageserver

# strip debug symbols
"$STRIP" "$PREFIX/bin/rune"
"$STRIP" "$PREFIX/bin/rune-languageserver"
