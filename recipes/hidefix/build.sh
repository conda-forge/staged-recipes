# Based on the build.sh for the pysyntect-feedstock recipe.
# https://github.com/conda-forge/pysyntect-feedstock/
set -ex

# Print Rust version
rustc --version

# https://github.com/rust-lang/cargo/issues/10583#issuecomment-1129997984
export CARGO_NET_GIT_FETCH_WITH_CLI=true

# Install wheel manually
export MATURIN_PEP517_ARGS="--features static,extension-module -vv"

$PYTHON -m pip install . --no-deps --ignore-installed -vv
