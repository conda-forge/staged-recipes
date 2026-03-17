#!/usr/bin/env bash
set -exuo pipefail

cd "${SRC_DIR}/dovi_tool_src"

if [[ -z "${CARGO_BUILD_TARGET:-}" && -n "${RUST_TARGET:-}" ]]; then
    export CARGO_BUILD_TARGET="${RUST_TARGET}"
fi

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=thin

cargo-bundle-licenses \
    --format yaml \
    --output "${SRC_DIR}/THIRDPARTY_dovi_tool.yml"

cargo auditable install \
    --locked \
    --no-track \
    --bins \
    --root "${PREFIX}" \
    --path .
