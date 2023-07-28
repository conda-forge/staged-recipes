#!/bin/bash

set -ex

export PYO3_PYTHON_VERSION=${PY_VER}

maturin build --release --interpreter="${PYTHON}" -m rerun_py/Cargo.toml --no-default-features --features pypi

"${PYTHON}" -m pip install $SRC_DIR/target/wheels/*.whl --no-deps -vv

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml 