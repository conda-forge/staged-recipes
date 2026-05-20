#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

# Remove this wrapper once https://github.com/conda-forge/rust-activation-feedstock/pull/79 is merged
mkdir -p "${BUILD_PREFIX}/bin"
cp "${RECIPE_DIR}/cargo-auditable-wrapper.sh" "${BUILD_PREFIX}/bin/cargo-auditable-wrapper"
export CARGO="cargo-auditable-wrapper"

# Bundle licenses
cargo-bundle-licenses --format yaml --output ${SRC_DIR}/THIRDPARTY.yml

# Build
python -m pip install . \
    --no-deps --ignore-installed -vv --no-build-isolation --disable-pip-version-check
