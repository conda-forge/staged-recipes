#!/usr/bin/env bash
set -eux

export CARGO_PROFILE_RELEASE_STRIP=symbols

cargo-bundle-licenses \
  --format yaml \
  --output "${SRC_DIR}/THIRDPARTY.yml"

# Run the maturin build via pip which works for direct and
# cross-compiled builds.
$PYTHON -m pip install . -vv
