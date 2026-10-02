#!/usr/bin/env bash
set -euo pipefail

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --locked --no-track --path . --root "$PREFIX" --bins

# Remove cargo metadata files that conda doesn't need
rm -f "$PREFIX/.crates.toml" "$PREFIX/.crates2.json"
