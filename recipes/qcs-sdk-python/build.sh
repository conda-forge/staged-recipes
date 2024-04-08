#!/bin/bash

set -ex

# windows shell doesn't start here
cd $SRC_DIR

# Patch package metadata for grpc-web
python crates/python/scripts/patch_grpc_web.py
cargo update hyper-proxy

# Build
maturin --release build --manifest-path crates/python/Cargo.toml --out $SRC_DIR/dist
pip install qcs-sdk-python --find-links dist --force-reinstall

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml