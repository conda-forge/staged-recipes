set -ex

# Bundle all downstream library licenses
cargo-bundle-licenses \
  --format yaml \
  --output ${SRC_DIR}/THIRDPARTY_LICENSES.yaml

maturin build -i $PYTHON --release

cd kornia-py/target/wheels

# Install wheel manually
$PYTHON -m pip install *.whl