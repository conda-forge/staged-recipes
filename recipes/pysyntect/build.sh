set -ex

# Install RustUp on Linux/MacOs
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Append Rust to PATH
export RUST_PATH=$HOME/.cargo/bin
export PATH=$PATH:$RUST_PATH

# Install Rust nightly
rustup default nightly

# Print Rust version
rustc --version

# Apply PEP517 to install the package
pip install -U .
