#!/usr/bin/env bash

set -euo pipefail

export OPENSSL_DIR=$PREFIX
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --locked --root "$PREFIX" --path .
"$STRIP" "$PREFIX/bin/pixi-pack"
