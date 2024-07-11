#!/usr/bin/env bash

set -euo pipefail

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --locked --root "$PREFIX" --path .
"$STRIP" "$PREFIX/bin/pixi-pack"
