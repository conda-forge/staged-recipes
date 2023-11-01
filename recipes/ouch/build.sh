#!/usr/bin/env bash

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml
cargo install --locked --bins --root "$PREFIX" --path .
"$STRIP" "$PREFIX/bin/ouch"
rm -f "${PREFIX}/.crates.toml"
rm -f "${PREFIX}/.crates2.json"
