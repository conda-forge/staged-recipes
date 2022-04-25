# Based on the build.sh for the pysyntect-feedstock recipe.
# https://github.com/conda-forge/pysyntect-feedstock/
set -ex

# Set conda CC as custom CC in Rust
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=$CC
export CARGO_TARGET_X86_64_APPLE_DARWIN_LINKER=$CC
export CARGO_TARGET_AARCH64_APPLE_DARWIN_LINKER=$CC

which rustup || curl https://sh.rustup.rs -sSf | sh -s -- --profile minimal --default-toolchain nightly -y
rustup toolchain install nightly
rustup default nightly

# Print Rust version
rustc --version

# Install cargo-license
# TODO


export CARGO_HOME="$BUILD_PREFIX/cargo"
mkdir $CARGO_HOME

# Check that all downstream libraries licenses are present
export PATH=$PATH:$CARGO_HOME/bin

# Apply PEP517 to install the package
maturin build --release -i $PYTHON

cd target/wheels

# Install wheel manually
$PYTHON -m pip install *.whl
