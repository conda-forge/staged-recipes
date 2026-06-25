#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CARGO_PROFILE_RELEASE_STRIP=symbols

cargo install --no-track --locked --root "$PREFIX" -p csv-utils
cargo install --no-track --locked --root "$PREFIX" -p csv-utils-web

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

rm -f "$PREFIX/.crates.toml" "$PREFIX/.crates2.json"
