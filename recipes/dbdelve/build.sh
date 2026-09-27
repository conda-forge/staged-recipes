#!/bin/bash
set -euxo pipefail

export CARGO_PROFILE_RELEASE_STRIP=symbols

cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"

cargo auditable install --locked --no-track --path . --target "${CARGO_BUILD_TARGET}" --root "${PREFIX}"
