#!/bin/bash
set -ex

# Clean any previous Rust build artifacts
cargo clean

# Bundle third-party licenses for Rust dependencies
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Install the package
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
