#!/bin/bash

set -ex

# Build the Rust binary with cargo
cargo install --locked --root "${PREFIX}" --path .

# Verify the binary was installed
ls -la "${PREFIX}/bin/tw"