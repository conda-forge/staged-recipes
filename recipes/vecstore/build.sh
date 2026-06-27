#!/bin/bash

set -ex

# Build with server feature enabled
cargo install --locked --features server --bin vecstore-server --path . --root $PREFIX

# Generate license file
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml
