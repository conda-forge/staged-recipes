#!/usr/bin/env bash

# Check licenses
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# Build
cargo install --locked --root "$PREFIX" --path packages/hurl
cargo install --locked --root "$PREFIX" --path packages/hurlfmt

# Remove extra build files
rm -f "${PREFIX}/.crates.toml"
rm -f "${PREFIX}/.crates2.json"

# Add the man pages
mkdir -p "${PREFIX}/share/man/man1"
cp docs/manual/{hurl,hurlfmt}.1 "${PREFIX}/share/man/man1"
