#!/usr/bin/env bash
set -euo pipefail
export OPENSSL_NO_VENDOR=1
export OPENSSL_DIR="${PREFIX}"
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --locked --no-track --root "${PREFIX}" --path .