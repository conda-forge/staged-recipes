#!/bin/bash
set -euxo pipefail
export CARGO_HOME="${SRC_DIR}/.cargo"
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
python -m pip install . --no-deps --no-build-isolation -vv
