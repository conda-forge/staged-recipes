#!/bin/bash

set -ex

# Script is called by bld.bat by windows shell, which doesn't start here
cd $SRC_DIR
cp ${RECIPE_DIR}/rust-toolchain .
cargo fix --lib -p cargo-make --allow-no-vcs
cargo build --bins --locked
cargo build --tests --locked
cargo test --bins --locked
cargo install --path . --root ${PREFIX} --locked
