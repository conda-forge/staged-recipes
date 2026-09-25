#!/usr/bin/env bash
set -ex

cd "${SRC_DIR}/b3sum"

# Bundle the licenses of all vendored Rust dependencies for the package.
cargo-bundle-licenses \
    --format yaml \
    --output "${SRC_DIR}/THIRDPARTY.yml"

cargo install --locked --no-track --root "${PREFIX}" --path .
