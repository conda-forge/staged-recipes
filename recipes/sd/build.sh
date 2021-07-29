#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

### Assert licenses are available
# Install cargo-license
export CARGO_HOME="$BUILD_PREFIX/cargo"
mkdir $CARGO_HOME
cargo install cargo-license --version 0.3.0 --locked

# Check that all downstream libraries licenses are present
export PATH=$PATH:$CARGO_HOME/bin
cargo-license --json > dependencies.json
cat dependencies.json

python $RECIPE_DIR/check_licenses.py

# build statically linked binary with Rust
cargo install --locked --root "$PREFIX" --path .

# strip debug symbols
"$STRIP" "$PREFIX/bin/sd"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
