#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit


cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
# with different parms for Linux and macOS
os_type=$(echo $OSTYPE | cut -c 1-6)
if [[ "$os_type" == "darwin" ]]; then
  export RUST_BACKTRACE=1
  cargo install --root "$PREFIX" --path . --no-default-features --target x86_64-apple-darwin --features apply,generate,lua,foreach
else
  cargo install --root "$PREFIX" --path . --features apply,generate,lua,foreach
fi

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
