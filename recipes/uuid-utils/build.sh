#!/bin/bash

set -ex

# Bundle all library licenses
cargo-bundle-licenses \
  --format yaml \
  --output ${SRC_DIR}/THIRDPARTY.yml

# Apply PEP517 to install the package

export RUSTFLAGS="--cfg uuid_unstable"
maturin build --release -i $PYTHON

cd target/wheels

# Install wheel manually
$PYTHON -m pip install *.whl