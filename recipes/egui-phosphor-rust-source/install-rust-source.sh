#!/usr/bin/env bash

set -euxo pipefail

cargo build --release --all-targets
cargo test --release --all-targets

# This is a Rust source distribution, we need to remove the target directory
rm -rf target

# Install source distribution
mkdir -p ${PREFIX}/src/rust-libraries/${PKG_NAME}-${PKG_VERSION}
cp -r ./* ${PREFIX}/src/rust-libraries/${PKG_NAME}-${PKG_VERSION}

# Adding the checksums of the source distribution to the recipe
cat > $PREFIX/src/rust-libraries/${PKG_NAME}-${PKG_VERSION}/.cargo-checksum.json << EOF
{"files":{},"package":"${PKG_SHA256}"}
EOF

cargo-bundle-licenses --format yaml --output "${RECIPE_DIR}"/THIRDPARTY.yml
