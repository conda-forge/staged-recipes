#!/usr/bin/env bash

set -euo pipefail

cargo build --release
$PYTHON -m pip install .
mkdir -p $SP_DIR/$PKG_NAME/bin
cp target/$CARGO_BUILD_TARGET/release/mosec $SP_DIR/$PKG_NAME/bin

# generate the license file
cargo install cargo-license
cargo license --authors --avoid-build-deps --avoid-dev-deps --do-not-bundle --all-features --json > license.json
