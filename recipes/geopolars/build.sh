#!/usr/bin/env bash

set -euxo pipefail

# The compiled Python extension lives in the py-geopolars crate, which is
# deliberately excluded from the workspace at the repository root.
cd py-geopolars

# Two crate versions pinned in Cargo.lock no longer build with a current rustc:
# ethnum 1.3.0 fails with E0512 (transmute between differently sized types) and
# geo-types 0.7.7 has a float literal that is now a hard parse error. Both are
# semver-compatible bumps that the manifests already allow.
cargo update --package ethnum --precise 1.5.3
cargo update --package geo-types --precise 0.7.19

# geozero pulls in prost-build unconditionally, and prost-build's own build
# script insists on locating a protoc even though geozero only runs protobuf
# codegen under its "with-mvt" feature, which is off here. Point it at the
# protoc from libprotobuf so it does not build its vendored protobuf via cmake.
export PROTOC="${BUILD_PREFIX}/bin/protoc"

cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"

maturin build --release --locked --jobs "${CPU_COUNT}" --out dist
"${PYTHON}" -m pip install dist/geopolars-*.whl --no-deps --no-build-isolation -vv
