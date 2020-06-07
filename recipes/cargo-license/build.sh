#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo install --locked --root "$PREFIX" --path .

"$STRIP" "$PREFIX/bin/cargo-license"

rm -f "${PREFIX}/.crates.toml"
