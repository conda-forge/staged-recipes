#!/bin/bash

set -ex

export PENDULUM_EXTENSIONS=1

maturin build -vv -j "${CPU_COUNT}" --release --strip --manylinux off --interpreter="${PYTHON}" "${_xtra_maturin_args[@]}"

# Bundle licenses
pushd "${SRC_DIR}"/rust
  cargo-bundle-licenses --format yaml --output "${RECIPE_DIR}"/THIRDPARTY.yml
popd

"${PYTHON}" -m pip install $SRC_DIR/rust/target/wheels/dlt_pendulum*.whl --no-deps -vv
