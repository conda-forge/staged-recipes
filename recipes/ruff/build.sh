set -ex

# Bundle all downstream library licenses
cargo-bundle-licenses \
  --format yaml \
  --output ${SRC_DIR}/THIRDPARTY.yml

# Apply PEP517 to install the package
maturin build --release -i $PYTHON

cd target/wheels

# Install wheel manually
$PYTHON -m pip install *.whl
