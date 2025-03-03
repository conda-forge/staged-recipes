#!/usr/bin/env bash
set -eux

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

"${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation --disable-pip-version-check

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
