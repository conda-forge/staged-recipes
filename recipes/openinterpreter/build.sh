#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="$CFLAGS -D_GNU_SOURCE"
export CXXFLAGS="$CXXFLAGS -D_GNU_SOURCE"

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

cd codex-rs
cargo-bundle-licenses --format yaml --output ../THIRDPARTY.yml

# Open Interpreter's upstream package variant builds the Cargo bin named
# "codex", then exposes it as "interpreter" with "i" as an alias.
if [ -n "${CARGO_BUILD_TARGET:-}" ]; then
    echo "Building for target: ${CARGO_BUILD_TARGET}"
    cargo auditable install --locked --no-track --bins --root "${PREFIX}" --path cli --target "${CARGO_BUILD_TARGET}"
else
    cargo auditable install --locked --no-track --bins --root "${PREFIX}" --path cli
fi

mv "${PREFIX}/bin/codex" "${PREFIX}/bin/interpreter"
ln -s interpreter "${PREFIX}/bin/i"

# Pixi: prevent CONDA_PREFIX from leaking into sandboxed processes
mkdir -p "${PREFIX}/etc/pixi/codex"
touch "${PREFIX}/etc/pixi/codex/global-ignore-conda-prefix"
