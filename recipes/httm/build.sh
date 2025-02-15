#!/usr/bin/env bash

set -euo pipefail

export OPENSSL_DIR=$PREFIX
export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --no-track --locked --root "$PREFIX" --path .
cp ./scripts/bowie.bash "$PREFIX/bin/bowie"
cp ./scripts/ounce.bash "$PREFIX/bin/ounce"
cp ./scripts/nicotine.bash "$PREFIX/bin/nicotine"
cp ./scripts/equine.bash "$PREFIX/bin/equine"
mkdir -p "$PREFIX/man/man1"
cp ./httm.1 "$PREFIX/man/man1/httm.1"
