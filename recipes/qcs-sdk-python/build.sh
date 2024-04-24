#!/bin/bash

set -ex

# Build
maturin build --release --manifest-path crates/python/Cargo.toml --out $SRC_DIR/wheels

# Re-build with patch package metadata for grpc-web
python crates/python/scripts/patch_grpc_web.py
cargo update hyper-proxy
maturin build --release --manifest-path crates/python/Cargo.toml --out $SRC_DIR/wheels

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
