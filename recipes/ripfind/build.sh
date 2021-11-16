#!/bin/bash

set -ex

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

cargo install --locked --root "$PREFIX" --path .


# strip debug symbols
"$STRIP" "$PREFIX/bin/rf"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
