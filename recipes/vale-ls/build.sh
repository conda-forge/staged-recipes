#!/usr/bin/env bash
set -o xtrace -o nounset -o pipefail -o errexit

export RUST_BACKTRACE=1

# TODO: remove after https://github.com/conda-forge/rust-activation-feedstock/issues/35
# "cargo" culted from https://github.com/conda-forge/cargo-c-feedstock/blob/main/recipe/build.sh
export CARGO_BUILD_RUSTFLAGS="$CARGO_BUILD_RUSTFLAGS -L all=$PREFIX/lib"

if [[ "$c_compiler" == "clang" ]]; then
  echo "-L$BUILD_PREFIX/lib -Wl,-rpath,$BUILD_PREFIX/lib" > $BUILD_PREFIX/bin/$BUILD.cfg
  echo "-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib" > $BUILD_PREFIX/bin/$HOST.cfg
fi

# build statically linked binary with Rust
cargo install --locked --root "${PREFIX}" --path .

# dump licenses
cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"

# remove extra build files
rm -f "${PREFIX}/.crates2.json" "${PREFIX}/.crates.toml"
