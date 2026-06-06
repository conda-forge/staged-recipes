#!/usr/bin/env bash

set -euxo pipefail

export LLVM_SYS_201_PREFIX="${PREFIX}"
export MATURIN_PEP517_ARGS="--features llvm20-1 --features llvm-sys-201/prefer-dynamic"
export MATURIN_STRIP=true

if [[ -n "${build_platform:-}" && -n "${target_platform:-}" && "${build_platform}" != "${target_platform}" ]]; then
  export PYO3_CROSS_INCLUDE_DIR="${PREFIX}/include"
  export PYO3_CROSS_LIB_DIR="${SP_DIR}/.."
  export PYO3_CROSS_PYTHON_VERSION="${PY_VER}"
fi

"${PYTHON}" -m pip install ./pyqir -vv --no-deps --no-build-isolation
cargo-bundle-licenses --features "llvm20-1,llvm-sys-201/prefer-dynamic" --format yaml --output THIRDPARTY.yml
