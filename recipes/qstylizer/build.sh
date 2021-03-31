set -ex

export PBR_VERSION=$PKG_VERSION

# Use PEP 517 to generate the wheel
$PYTHON setup.py bdist_wheel
cd dist/

# Install wheel manually
$PYTHON -m pip install *.whl
