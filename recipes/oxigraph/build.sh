#!/usr/bin/env bash
set -eux

export RUST_BACKTRACE=1

export CARGO_HOME="$BUILD_PREFIX/cargo"
export PATH=$PATH:$CARGO_HOME/bin

mkdir -p $CARGO_HOME

cargo install cargo-license --version 0.3.0 --locked

cargo-license --json > $SRC_DIR/$PKG_NAME-$PKG_VERSION-cargo-dependencies.json

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
