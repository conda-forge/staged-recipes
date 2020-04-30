set -ex

# Set conda CC as custom CC in Rust
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=$CC

# Print Rust version
rustc --version

# Install cargo-license
cargo install cargo-license

# Check that all downstream libraries licenses are present
export PATH=$PATH:/home/conda/.cargo/bin
cargo-license --json > $RECIPE_DIR/dependencies.json
cat $RECIPE_DIR/dependencies.json

python $RECIPE_DIR/check_licenses.py

# Apply PEP517 to install the package
maturin build --release -i $PYTHON

cd target/wheels

# Install wheel manually
pip install *.whl
