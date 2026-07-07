#!/bin/bash
set -euxo pipefail

# Build and install the bws binary from the workspace crate.
# Requires network access to fetch crates from crates.io.
cargo install --no-track --root "${PREFIX}" --path crates/bws
