#!/bin/bash
set -euxo pipefail

# The crates.io release is fetched as a tarball but not auto-extracted (the
# source sets a file_name), so unpack it here.
tar -xzf "office2pdf-cli-${PKG_VERSION}.tar.gz"
cd "office2pdf-cli-${PKG_VERSION}"

# Collect the licenses of every vendored Rust dependency next to LICENSE.
cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"

# office2pdf-cli produces the `office2pdf` binary.
cargo install --locked --no-track --root "${PREFIX}" --path .
