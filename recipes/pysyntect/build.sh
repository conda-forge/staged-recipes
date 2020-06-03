set -ex

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

# Apply PEP517 to install the package
maturin build --release -i $PYTHON

cd target/wheels

# Install wheel manually
pip install *.whl
