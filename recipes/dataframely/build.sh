#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

# Bundle licenses
cargo-bundle-licenses --format yaml --output ${SRC_DIR}/THIRDPARTY.yml

# Build
python -m pip install . \
    --no-deps --ignore-installed -vv --no-build-isolation --disable-pip-version-check
