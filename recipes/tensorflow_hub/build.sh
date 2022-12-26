set -ex
python -m pip install --no-deps --ignore-installed ./tensorflow_hub-${PKG_VERSION}-py2.py3-none-any.whl
# Remove the strict protobuf requirement. Conda will manage it.
sed -i.bak 's/protobuf>=3.4.0/protobuf/' ${SP_DIR}/tensorflow_hub/__init__.py