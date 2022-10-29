#!/usr/bin/env bash

set -ex

maturin build --release --strip --manylinux off --interpreter="${PYTHON}" --out dist

"${PYTHON}" -m pip install $SRC_DIR/dist/nh3*.whl --no-deps -vv

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
