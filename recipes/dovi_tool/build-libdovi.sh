#!/usr/bin/env bash
set -exuo pipefail

cd "${SRC_DIR}/libdovi_src/dolby_vision"

if [[ -z "${CARGO_BUILD_TARGET:-}" && -n "${RUST_TARGET:-}" ]]; then
    export CARGO_BUILD_TARGET="${RUST_TARGET}"
fi

cargo-bundle-licenses \
    --format yaml \
    --output "${SRC_DIR}/THIRDPARTY_libdovi.yml"

cargo cinstall \
    --locked \
    --release \
    --prefix "${PREFIX}" \
    --libdir "${PREFIX}/lib" \
    --includedir "${PREFIX}/include"

rm -f "${PREFIX}/lib/libdovi.a"
