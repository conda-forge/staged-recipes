#!/bin/bash

set -ex

# Bundle all library licenses
cargo-bundle-licenses \
  --format yaml \
  --output ${SRC_DIR}/THIRDPARTY.yml

cargo install --locked --root "$PREFIX" --path .

# strip debug symbols
"$STRIP" "$PREFIX/bin/silicon"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"