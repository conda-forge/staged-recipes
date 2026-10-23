#!/usr/bin/env bash
set -euxo pipefail

# Release tarballs retain placeholder versions for the workspace crates.
sed -i.bak "s/^version = \"0.0.0\"$/version = \"${PKG_VERSION}\"/" Cargo.toml Cargo.lock

export PROTOC="${BUILD_PREFIX}/bin/protoc"
export PROTOC_INCLUDE="${BUILD_PREFIX}/include"
export CARGO_PROFILE_RELEASE_STRIP=symbols

cargo auditable install --locked --no-track --root "${PREFIX}" --path crates/openshell-cli --bin openshell
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
