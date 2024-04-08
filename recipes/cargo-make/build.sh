#!/bin/bash

set -ex

# Script is called by bld.bat by windows shell, which doesn't start here
cd $SRC_DIR
cp ${RECIPE_DIR}/rust-toolchain .
cargo fix --lib -p cargo-make --allow-no-vcs
cargo install --path . --root ${PREFIX} --locked
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
