#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit


cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
# with different parms for Linux and macOS
os_type=$(echo $OSTYPE | cut -c 1-6)
if [[ "$os_type" == "darwin" ]]; then
  rustup target add x86_64-apple-darwin
  cargo install --root "$PREFIX" --path . --no-default-features --target x86_64-apple-darwin
else
  cargo install --root "$PREFIX" --path . 
fi

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
