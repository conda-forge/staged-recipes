#!/usr/bin/env bash
set -o xtrace -o nounset -o pipefail -o errexit

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses \
    --format yaml \
    --output "${SRC_DIR}/THIRDPARTY.yml"

# Public CLIs only (skip snapper-gen-docs). snapper-fmt is the alias for
# hosts that already own openSUSE's /usr/bin/snapper.
cargo install --locked --no-track \
    --bin snapper --bin snapper-fmt \
    --root "${PREFIX}" --path .

test -x "${PREFIX}/bin/snapper"
test -x "${PREFIX}/bin/snapper-fmt"
test -f "${SRC_DIR}/LICENSE"
test -f "${SRC_DIR}/THIRDPARTY.yml"
