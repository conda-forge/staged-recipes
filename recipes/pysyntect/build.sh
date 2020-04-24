set -ex

# Install RustUp on Linux/MacOs
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Append Rust to PATH
export RUST_PATH=$HOME/.cargo/bin
export PATH=$PATH:$RUST_PATH:$CC:$BUILD_PREFIX/bin/llvm-config

# Install Rust nightly
rustup default nightly

# Set conda CC as custom CC in Rust
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=$CC

# Print Rust version
rustc --version

# Apply PEP517 to install the package
maturin build --release -i $PYTHON

cd target/wheels

# Install wheel manually
pip install *.whl
