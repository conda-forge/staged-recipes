set -ex

maturin build -i $PYTHON --release

cd kornia-py/target/wheels

# Install wheel manually
$PYTHON -m pip install *.whl