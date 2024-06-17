#!/bin/bash

set -ex

declare -a _xtra_maturin_args
#_xtra_maturin_args+=(--cargo-extra-args="-Zfeatures=itarget")
_xtra_maturin_args+=(-Zfeatures=itarget)

maturin build --release --strip --manylinux off --interpreter="${PYTHON}" "${_xtra_maturin_args[@]}"

"${PYTHON}" -m pip install $SRC_DIR/target/wheels/xorjson*.whl --no-deps -vv

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml