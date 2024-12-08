#!/usr/bin/env bash

set -euxo pipefail

cargo build --release --manifest-path=bindgen/Cargo.toml --features=bin --verbose
cargo test --release --manifest-path=bindgen/Cargo.toml --features=bin --verbose
CARGO_TARGET_DIR=target cargo install --features=bin --path bindgen --root "${PREFIX}"
cargo-bundle-licenses --format yaml --output "${RECIPE_DIR}"/THIRDPARTY.yml
