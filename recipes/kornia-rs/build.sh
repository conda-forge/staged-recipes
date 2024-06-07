set -ex

make build-python-release

cd target/wheels

# Install wheel manually
$PYTHON -m pip install *.whl