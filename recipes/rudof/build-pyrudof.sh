#!/usr/bin/env bash
set -eux -o pipefail

export OPENSSL_DIR="${PREFIX}"

cd python

"${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation --disable-pip-version-check

cargo-bundle-licenses \
  --format yaml \
  --output "${SRC_DIR}/THIRDPARTY.yml"
