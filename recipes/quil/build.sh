#!/bin/bash

set -ex

# Build quil-py and quil-cli wheels
echo "Building wheels"
maturin build --release --manifest-path=${SRC_DIR}/quil-py/Cargo.toml --out ${SRC_DIR}/wheels
maturin build --release --manifest-path=${SRC_DIR}/quil-cli/Cargo.toml --out ${SRC_DIR}/wheels

# Update license file
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# ${PYTHON} -m pip install quil \
#   --no-build-isolation \
#   --no-deps \
#   --only-binary :all: \
#   --find-links=wheels/ \
#   --prefix ${PREFIX}

# ${PYTHON} -m pip install quil-cli \
#   --no-build-isolation \
#   --no-deps \
#   --only-binary :all: \
#   --find-links=wheels-cli/ \
#   --prefix ${PREFIX}

