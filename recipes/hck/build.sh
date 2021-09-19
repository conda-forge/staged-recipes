#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

### Assert licenses are available
# Install cargo-license
export CARGO_HOME="$BUILD_PREFIX/cargo"
mkdir $CARGO_HOME
cargo install cargo-bundle-licenses

# Check that all downstream libraries licenses are present
export PATH=$PATH:$CARGO_HOME/bin
cargo bundle-licenses --format yaml --output CI.THIRDPARTY.yml --previous THIRDPARTY.yml --check-previous

# build statically linked binary with Rust
cargo install --locked --root "$PREFIX" --path .

# strip debug symbols
"$STRIP" "$PREFIX/bin/hck"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
