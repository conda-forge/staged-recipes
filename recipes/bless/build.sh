#!/usr/bin/env bash
set -euxo pipefail
cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"
cargo install --locked --no-track --bin bless --root "${PREFIX}" --path .
test -x "${PREFIX}/bin/bless"
