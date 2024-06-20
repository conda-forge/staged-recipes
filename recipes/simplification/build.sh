#!/bin/bash
set -ex

cd src/simplification/rdp

# Bundle all downstream library licenses
cargo-bundle-licenses \
  --format yaml \
  --output ${SRC_DIR}/THIRDPARTY_LICENSES.yaml

# Build the Rust library
CARGO_INCREMENTAL="0" cargo build --release

# Copy the built library and header to the root of the source directory
cp include/header.h ../
if [ ${target_platform} == *"linux"* ]; then
	cp target/release/librdp.so ../
elif [ ${target_platform} == *"osx"* ]; then
	cp target/release/librdp.dylib ../
fi

cd ../
rm -rf rdp

# Build the Python package
$PYTHON -m pip install . -vv --no-deps --no-build-isolation
