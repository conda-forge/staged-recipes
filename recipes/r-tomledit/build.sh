#!/usr/bin/env bash
set -ex

unset NOT_CRAN
export CARGO_NET_OFFLINE=true
unset CARGO_BUILD_TARGET

# Set up the vendored Rust deps up front so every cargo operation runs fully
# offline — conda-forge's linux-anvil sandbox cannot reach crates.io. The
# package's Makevars repeats this setup during R CMD INSTALL; doing it here
# first lets us bundle licenses below. Layout must match the Makevars:
# vendor extracted under src/ (so `directory = "vendor"` in vendor-config.toml,
# resolved relative to src/.cargo, matches), CARGO_HOME = src/.cargo.
CARGOTMP="${SRC_DIR}/src/.cargo"
mkdir -p "${CARGOTMP}"
cp src/rust/vendor-config.toml "${CARGOTMP}/config.toml"
( cd src && tar xf rust/vendor.tar.xz )

# conda-forge requires Rust packages to bundle third-party licenses.
# cargo-bundle-licenses reads Cargo.toml from the CWD (no --manifest-path).
( cd src/rust && CARGO_HOME="${CARGOTMP}" cargo bundle-licenses \
    --format yaml \
    --output "${SRC_DIR}/THIRDPARTY.yml" )

R --vanilla CMD INSTALL --build .
