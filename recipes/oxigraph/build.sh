#!/usr/bin/env bash
set -eux

export RUST_BACKTRACE=1
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=$CC

pushd server
    cargo build --release
popd

pushd wikibase
    cargo build --release
popd

pushd python
    maturin build --release -i $PYTHON
popd

find target
