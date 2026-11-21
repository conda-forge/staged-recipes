#!/bin/bash
set -ex

cargo install --locked --features server --bin vecstore-server --path . --root "$PREFIX"
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
