#!/bin/bash

set -ex

maturin build --no-sdist --release --strip --manylinux off --interpreter="${PYTHON}"

"${PYTHON}" -m pip install $SRC_DIR/target/wheels/polars*.whl --no-deps -vv

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml