#!/bin/bash

set -ex

# Build
maturin build --release --manifest-path=quil-py/Cargo.toml --out wheels
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

${PYTHON} -m pip install quil \
  --no-build-isolation \
  --no-deps \
  --only-binary :all: \
  --find-links=wheels/ \
  --prefix ${PREFIX}

maturin build --release --manifest-path=quil-cli/Cargo.toml --out wheels-cli
${PYTHON} -m pip install quil-cli \
  --no-build-isolation \
  --no-deps \
  --only-binary :all: \
  --find-links=wheels-cli/ \
  --prefix ${PREFIX}

