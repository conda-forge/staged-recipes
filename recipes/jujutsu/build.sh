#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

# build statically linked binary with Rust
if [ "$(uname)" = "Darwin" ]; then
    cargo install --features vendored-openssl --no-track --locked --root "$PREFIX" --path ./cli --bin jj jj-cli
else
    cargo install --no-track --locked --root "$PREFIX" --path ./cli --bin jj jj-cli
fi

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml
