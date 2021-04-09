# Based on the build.sh for the pysyntect-feedstock recipe.
# https://github.com/conda-forge/pysyntect-feedstock/
set -ex

# Set conda CC as custom CC in Rust
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=$CC

# Print Rust version
rustc --version

# Apply PEP517 to install the package
maturin build --release -i $PYTHON

cd target/wheels

# Install wheel manually
$PYTHON -m pip install *.whl
