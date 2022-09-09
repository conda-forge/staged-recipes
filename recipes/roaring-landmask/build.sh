# Based on the build.sh for the pysyntect-feedstock recipe.
# https://github.com/conda-forge/pysyntect-feedstock/
set -ex

# Set conda CC as custom CC in Rust
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=$CC
export CARGO_TARGET_X86_64_APPLE_DARWIN_LINKER=$CC
export CARGO_TARGET_AARCH64_APPLE_DARWIN_LINKER=$CC

# Print Rust version
rustc --version

# https://github.com/rust-lang/cargo/issues/10583#issuecomment-1129997984
export CARGO_NET_GIT_FETCH_WITH_CLI=true

# Install wheel manually
export MATURIN_PEP517_ARGS="--no-default-features --features extension-module"

$PYTHON -m pip install . --no-deps --ignore-installed -vv
