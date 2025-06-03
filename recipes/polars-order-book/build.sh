#!/bin/bash
set -euxo pipefail

# Set Rust-specific environment variables for optimization
export CARGO_NET_GIT_FETCH_WITH_CLI=true
export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

# Memory optimization for large Rust builds
export CARGO_BUILD_JOBS=${CPU_COUNT:-1}

# Use maturin directly (more control than pip install)
$PYTHON -m maturin build --release --strip --interpreter $PYTHON
$PYTHON -m pip install target/wheels/*.whl -vv --no-deps