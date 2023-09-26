#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
# with different parms for Linux and macOS
os_type=$(echo $OSTYPE | cut -c 1-6)
if [[ "$os_type" == "darwin" ]]; then
  export RUST_BACKTRACE=full
  cargo install --root "$PREFIX" --path . --no-default-features --locked --target x86_64-apple-darwin --features feature_capable,apply,generate,luau,foreach,fetch,polars,geocode,to
else
  cargo install --root "$PREFIX" --path . --locked --features feature_capable,apply,generate,luau,foreach,fetch,polars,geocode,to
fi

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
