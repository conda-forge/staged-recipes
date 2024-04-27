#!/bin/bash

set -ex

# Build quil-py and quil-cli wheels
maturin build --release --manifest-path=${SRC_DIR}/quil-py/Cargo.toml --out ${SRC_DIR}/wheels
maturin build --release --manifest-path=${SRC_DIR}/quil-cli/Cargo.toml --out ${SRC_DIR}/wheels

# Update license file
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

