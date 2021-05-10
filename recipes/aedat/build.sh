#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# build statically linked library with Rust
cargo build --lib --release
mkdir -p $SP_DIR/$PKG_NAME
cp target/x86_64-unknown-linux-gnu/release/libaedat${SHLIB_EXT} $SP_DIR/$PKG_NAME/libaedat.so

# remove extra build file
rm -f "${PREFIX}/.crates.toml"

# drop a version file with parseable info
VERSION_FPATH=$SP_DIR/$PKG_NAME/VERSION
echo "PKG_NAME: $PKG_NAME" > $VERSION_FPATH
echo "PKG_VERSION: $PKG_VERSION" >> $VERSION_FPATH
echo "PKG_BUILD_STRING: $PKG_BUILD_STRING" >> $VERSION_FPATH
BUILD_DATE=`date +%Y-%m-%d`
echo "BUILD_DATE: $BUILD_DATE" >> $VERSION_FPATH
