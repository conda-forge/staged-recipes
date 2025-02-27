#!/usr/bin/env bash

set -euo pipefail

export OPENSSL_DIR=$PREFIX
export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

pushd crates/rattler_index
cargo-bundle-licenses --format yaml --output ../../THIRDPARTY.yml
cargo install --no-track --locked --features native-tls --no-default-features --root "$PREFIX" --path .
