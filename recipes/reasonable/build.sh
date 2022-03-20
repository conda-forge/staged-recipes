#!/usr/bin/env bash
set -eux

export RUST_BACKTRACE=1

export CARGO_HOME="$BUILD_PREFIX/cargo"
export PATH=$PATH:$CARGO_HOME/bin

export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=$CC
export CARGO_TARGET_X86_64_APPLE_DARWIN_LINKER=$CC
export CARGO_TARGET_AARCH64_APPLE_DARWIN_LINKER=$CC
export PYO3_PYTHON=$PYTHON


rustc --version

mkdir -p $CARGO_HOME

cargo-bundle-licenses \
    --format yaml \
    --output ${SRC_DIR}/THIRDPARTY.yml

maturin build \
    --release \
    -i $PYTHON \
    -b pyo3 \
    --cargo-extra-args="--features python-library"

$PYTHON -m pip install $SRC_DIR/target/wheels/*.whl

rm -f "${PREFIX}/.crates.toml"
rm -f "${PREFIX}/.crates2.json"
