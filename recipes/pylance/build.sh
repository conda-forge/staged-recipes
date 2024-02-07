#!/usr/bin/env bash
set -ex
# Bundle all downstream library licenses
cd python
cargo-bundle-licenses \
  --format yaml \
  --output ${SRC_DIR}/THIRDPARTY.yml

# Apply PEP517 to install the package
maturin build \
  --release \
  --strip \
  --manylinux off \
  --interpreter="${PYTHON}"

# Install wheel manually
cd target/wheels
"${PYTHON}" -m pip install *.whl -vv --no-deps
