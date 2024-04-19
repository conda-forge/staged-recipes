#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export RUST_BACKTRACE=1
export OPENSSL_DIR=$PREFIX

# build
cargo install --locked \
    --root "$PREFIX" \
    --path sqlx-cli

# strip debug symbols
"$STRIP" "$PREFIX/bin/cargo-sqlx"
"$STRIP" "$PREFIX/bin/sqlx"

cargo-bundle-licenses \
    --format yaml \
    --output "${SRC_DIR}/THIRDPARTY.yml"

# remove extra build files
rm -f "${PREFIX}/.crates2.json" "${PREFIX}/.crates.toml"
