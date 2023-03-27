#!/usr/bin/env bash
set -eux

export RUST_BACKTRACE=1

export CARGO_HOME="${BUILD_PREFIX}/cargo"
export PATH="${PATH}:${CARGO_HOME}/bin"

export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="${CC}"
export CARGO_TARGET_X86_64_APPLE_DARWIN_LINKER="${CC}"
export CARGO_TARGET_AARCH64_APPLE_DARWIN_LINKER="${CC}"

rustc --version

mkdir -p "${CARGO_HOME}"

maturin build --release --strip --manylinux off -i "${PYTHON}"

"${PYTHON}" -m pip install fast-query-parsers -vv --no-deps --no-index --find-links "${SRC_DIR}/target/wheels"

cargo-bundle-licenses \
    --format yaml \
    --output "${SRC_DIR}/THIRDPARTY.yml"
