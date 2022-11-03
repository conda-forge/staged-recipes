set -ex

export PBR_VERSION=$PKG_VERSION

cd $SRC_DIR/jpy
# Use PEP 517 to generate the wheel
$PYTHON setup.py --maven bdist_wheel
cd dist/

# Install wheel manually
$PYTHON -m pip install *.whl