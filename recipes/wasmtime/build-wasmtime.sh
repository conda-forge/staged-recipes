#!/usr/bin/env bash
set -eux -o pipefail

if [[ "${PKG_NAME}" == "python-wasmtime" ]]; then
    cd wasmtime-py
    python -m pip install . --no-deps --no-build-isolation --disable-pip-version-check
    exit 0
fi

export CARGO_PROFILE_RELEASE_CODEGEN_UNITS=1
export CARGO_PROFILE_RELEASE_LTO=true
export CARGO_PROFILE_RELEASE_OPT_LEVEL=s
export CARGO_PROFILE_RELEASE_PANIC=abort
export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_TARGET_DIR=target

if [[ "${PKG_NAME}" == "libwasmtime" ]]; then
    cd wasmtime
    cargo build -p wasmtime-c-api --release
    mkdir -p "${PREFIX}/lib" "${PREFIX}/include"
    cp "target/${CARGO_BUILD_TARGET}/release/libwasmtime${SHLIB_EXT}" "${PREFIX}/lib"
    cd crates/c-api
    cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
    cd include
    cp -r ./*.h ./*.hh ./wasmtime/ "${PREFIX}/include"
    exit 0
fi

if [[ "${PKG_NAME}" == "wasmtime" ]]; then
    cd wasmtime
    cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
    cargo install \
        --no-track \
        --locked \
        --profile release \
        --root "${PREFIX}" \
        --path .
    exit 0
fi

echo "unexpected ${PKG_NAME}"

exit 99
