#!/usr/bin/env bash
set -euxo pipefail

pushd crates/lance-csr-python
cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"
popd

"${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation
