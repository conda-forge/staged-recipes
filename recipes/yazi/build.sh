#!/usr/bin/env bash

set -euxo pipefail
export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

cargo install --no-track --locked --root "${PREFIX}" yazi-fm yazi-cli
cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"

