#!/usr/bin/env bash

set -euo pipefail

cargo build --release
mkdir -p mosec/bin
cp target/$CARGO_BUILD_TARGET/release/mosec mosec/bin
pip install .

# generate the license file
cargo install cargo-license
cargo license --direct-deps-only --authors --avoid-build-deps --avoid-dev-deps --do-not-bundle --all-features --json > license.json
