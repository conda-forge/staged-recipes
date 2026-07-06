#!/usr/bin/env bash
set -o xtrace -o nounset -o pipefail -o errexit

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses \
    --format yaml \
    --output "${SRC_DIR}/THIRDPARTY.yml"

# Install only the public CLI binary (skip snapper-gen-docs).
cargo install --locked --no-track --bin snapper --root "${PREFIX}" --path .

test -x "${PREFIX}/bin/snapper"
test -f "${SRC_DIR}/LICENSE"
test -f "${SRC_DIR}/THIRDPARTY.yml"
