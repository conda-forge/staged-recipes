#!/usr/bin/env bash

set -euxo pipefail

cargo install --locked --root "${PREFIX}" yazi-fm yazi-cli
cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"

rm "$PREFIX/.crates2.json"
rm "$PREFIX/.crates.toml"
