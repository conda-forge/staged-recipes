#!/usr/bin/env bash
# NOTE: mostly derived from https://github.com/conda-forge/py-spy-feedstock/blob/master/recipe/build.sh
set -o xtrace -o nounset -o pipefail -o errexit

export RUST_BACKTRACE=1

if [ $(uname) = Darwin ] ; then
  export RUSTFLAGS="-C link-args=-Wl,-rpath,${PREFIX}/lib"
else
  export RUSTFLAGS="-C link-arg=-Wl,-rpath-link,${PREFIX}/lib -L${PREFIX}/lib"
fi

cd lib/cli

# build statically linked binary with Rust
cargo install --locked --root "$PREFIX" --path . --features "cranelift llvm singlepass"

# install cargo-license and dump licenses
export CARGO_LICENSES_FILE=$SRC_DIR/$PKG_NAME-$PKG_VERSION-cargo-dependencies.json

cargo install --root "$BUILD_PREFIX" cargo-license
cargo-license --json > $CARGO_LICENSES_FILE
ls -lathr $CARGO_LICENSES_FILE
# TODO: remove this?
cat $CARGO_LICENSES_FILE

# remove extra build files
rm -f "${PREFIX}/.crates2.json"
rm -f "${PREFIX}/.crates.toml"
