#!/usr/bin/env bash

set -exo pipefail

export CFLAGS="${CFLAGS:-} -D_GNU_SOURCE"
export CXXFLAGS="${CXXFLAGS:-} -D_GNU_SOURCE"

if [[ ${OSTYPE} == "linux"* && "${build_platform:-}" != "${target_platform:-}" ]]; then
    export PKG_CONFIG_ALLOW_CROSS=1
    export OPENSSL_DIR="${PREFIX}"
fi

if [[ "${target_platform:-}" == "linux-aarch64" ]]; then
    export CARGO_BUILD_JOBS="${CARGO_BUILD_JOBS:-1}"
    export CARGO_PROFILE_RELEASE_CODEGEN_UNITS="${CARGO_PROFILE_RELEASE_CODEGEN_UNITS:-1}"
    export CARGO_PROFILE_RELEASE_DEBUG="${CARGO_PROFILE_RELEASE_DEBUG:-false}"
    export CARGO_PROFILE_RELEASE_LTO="${CARGO_PROFILE_RELEASE_LTO:-off}"
    export RUSTFLAGS="${RUSTFLAGS:+${RUSTFLAGS} }-C link-arg=-Wl,--no-keep-memory"
fi

just assemble-codex-package --variant open-interpreter --cargo-profile release \
    --package-dir out --target "${CARGO_BUILD_TARGET}" --rg-bin "${PREFIX}/bin/rg"
python "${RECIPE_DIR}/install_package.py" out "${PREFIX}"

cd codex-rs
cargo-bundle-licenses --format yaml --output ../THIRDPARTY.yml
