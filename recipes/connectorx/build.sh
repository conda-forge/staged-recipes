#!/bin/bash

set -ex

cp $SRC_DIR/README.md $SRC_DIR/connectorx-python/README.md
cp $SRC_DIR/LICENSE $SRC_DIR/connectorx-python/LICENSE

pushd $SRC_DIR/connectorx-python
poetry install
popd

export RUSTFLAGS='-C target-feature=+fxsr,+sse,+sse2,+sse3,+ssse3,+sse4.1,+sse4.2,+popcnt,+fma'

maturin build --no-sdist --release --strip --manylinux off --interpreter="${PYTHON}" -m connectorx-python/Cargo.toml

"${PYTHON}" -m pip install $SRC_DIR/connectorx-python/target/wheels/*.whl --no-deps -vv

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml 
