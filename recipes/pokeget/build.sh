#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --no-track --locked --root "$PREFIX" --path .
