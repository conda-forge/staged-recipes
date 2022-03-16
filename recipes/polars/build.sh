# Based on the build.sh for the pysyntect-feedstock recipe.
# https://github.com/conda-forge/pysyntect-feedstock/
set -ex

# Set conda CC as custom CC in Rust
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=$CC
export CARGO_TARGET_X86_64_APPLE_DARWIN_LINKER=$CC
export CARGO_TARGET_AARCH64_APPLE_DARWIN_LINKER=$CC

curl https://sh.rustup.rs -sSf | sh -s -- --profile minimal --default-toolchain nightly -y
rustup toolchain install nightly
rustup default nightly

# Print Rust version
rustc --version

# Install wheel manually
$PYTHON -m pip install . --no-deps --ignore-installed -vv
