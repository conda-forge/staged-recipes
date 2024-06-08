set -ex

maturin build -i $PYTHON --release

cd target/wheels

# Install wheel manually
$PYTHON -m pip install *.whl