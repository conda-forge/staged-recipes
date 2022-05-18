#!/bin/bash

set -ex

# todo: Check +avx when supported in conda-forge
export RUSTFLAGS='-C target-feature=+fxsr,+sse,+sse2,+sse3,+ssse3,+sse4.1,+sse4.2,+popcnt,+fma'

maturin build --no-sdist --release --strip --manylinux off --interpreter="${PYTHON}"

"${PYTHON}" -m pip install $SRC_DIR/target/wheels/polars*.whl --no-deps -vv

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml