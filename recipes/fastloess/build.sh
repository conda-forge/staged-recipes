#!/bin/bash
set -ex

cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"

cd bindings/python
$PYTHON -m pip install . --no-build-isolation -vv
