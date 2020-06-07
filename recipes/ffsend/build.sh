#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export RUSTFLAGS="-L $PREFIX/lib"
cargo install --locked --root "$PREFIX" --path .

"$STRIP" "$PREFIX/bin/ffsend"

rm -f "${PREFIX}/.crates.toml"
