### Assert licenses are available
cp $RECIPE_DIR/Cargo.lock .
# Install cargo-license
export CARGO_HOME="$BUILD_PREFIX/cargo"
mkdir $CARGO_HOME
cargo install cargo-license --version 0.4.2 --locked

# Check that all downstream libraries licenses are present
export PATH=$PATH:$CARGO_HOME/bin
cargo-license --json > dependencies.json
cat dependencies.json
python $RECIPE_DIR/check_licenses.py

cargo install --locked --root "$PREFIX" --path .

# strip debug symbols
"$STRIP" "$PREFIX/bin/tango-controls-tui"

# remove extra build file
rm -f "${PREFIX}/.crates.toml" "${PREFIX}/.crates2.json"
