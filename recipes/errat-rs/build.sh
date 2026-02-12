#!/usr/bin/env bash
set -euo pipefail

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --locked --no-track --path . --root "$PREFIX" --bins

# Remove cargo metadata files that conda doesn't need
rm -f "$PREFIX/.crates.toml" "$PREFIX/.crates2.json"
