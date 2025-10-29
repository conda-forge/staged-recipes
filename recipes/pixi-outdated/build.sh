#!/usr/bin/env bash

set -euo pipefail

export OPENSSL_DIR=$PREFIX
export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --no-track --locked --root "$PREFIX" --path .
