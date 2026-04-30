#!/usr/bin/env bash
set -euo pipefail

# Keep Cargo's registry/cache inside the source tree so conda-build's
# isolation is not affected by the user's global ~/.cargo.
export CARGO_HOME="${SRC_DIR}/.cargo"

# Build the release binary
cargo build --release --bin sc

# Install binary
install -m 755 -d "${PREFIX}/bin"
install -m 755 "${SRC_DIR}/target/release/sc" "${PREFIX}/bin/sc"
