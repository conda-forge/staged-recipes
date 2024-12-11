#!/usr/bin/env bash

set -euxo pipefail

export CARGO_TARGET_X86_64_APPLE_DARWIN_LINKER=$CC
export CARGO_TARGET_AARCH64_APPLE_DARWIN_LINKER=$CC

BINDGEN_EXTRA_CLANG_ARGS="-v ${CPPFLAGS} ${CFLAGS}"
if [[ "${target_platform}" == osx-arm64 ]]; then
    BINDGEN_EXTRA_CLANG_ARGS="${BINDGEN_EXTRA_CLANG_ARGS} --target=aarch64-apple-darwin"
else
    BINDGEN_EXTRA_CLANG_ARGS="${BINDGEN_EXTRA_CLANG_ARGS} --target=x86_64-apple-darwin13.4.0"
fi
export LIBCLANG_PATH=${BUILD_PREFIX}/lib

cargo fix --lib -p apple-bindgen --allow-no-vcs
cargo build --release --manifest-path=bindgen/Cargo.toml --features=bin
cargo test --release --manifest-path=bindgen/Cargo.toml --features=bin --verbose -- --nocapture
CARGO_TARGET_DIR=target cargo install --features=bin --path bindgen --root "${PREFIX}"

cargo-bundle-licenses --format yaml --output "${RECIPE_DIR}"/THIRDPARTY.yml
