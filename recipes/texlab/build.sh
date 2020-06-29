#!/usr/bin/env bash
set -eux

# Set conda CC as custom CC in Rust
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=$CC

# Print Rust version
rustc --version

# Install cargo-license
export CARGO_HOME="$BUILD_PREFIX/cargo"
mkdir $CARGO_HOME
cargo install cargo-license

# Check that all downstream libraries licenses are present
export PATH=$PATH:$CARGO_HOME/bin
cargo-license --json > dependencies.json
cat dependencies.json

python $RECIPE_DIR/check_licenses.py

# actually build
cargo build --release

# install
mkdir -p "${PREFIX}/bin"
cp target/release/${PKG_NAME} "${PREFIX}/bin"
