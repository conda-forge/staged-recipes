#!/bin/bash

set -euxo pipefail

export PYO3_PYTHON="$PYTHON"

# Remove this wrapper once https://github.com/conda-forge/rust-activation-feedstock/pull/79 is merged
mkdir -p ${BUILD_PREFIX}/bin
cp ${RECIPE_DIR}/cargo-auditable-wrapper.sh ${BUILD_PREFIX}/bin/cargo-auditable-wrapper
export CARGO="cargo-auditable-wrapper"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
