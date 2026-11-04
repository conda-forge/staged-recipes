#!/usr/bin/env bash
set -euxo pipefail

# rust-activation selects the target triple, including osx-64 -> osx-arm64.
: "${CARGO_BUILD_TARGET:?The conda-forge Rust compiler must select a target}"
export CARGO_HOME="${SRC_DIR}/.cargo-home"
export CARGO_TARGET_DIR="${SRC_DIR}/target"
export CARGO_BUILD_JOBS="${CPU_COUNT}"
export CARGO_PROFILE_RELEASE_STRIP=symbols
export MATURIN_PEP517_ARGS="--locked --target ${CARGO_BUILD_TARGET}"

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" ]]; then
    export PYO3_CROSS=1
    export PYO3_CROSS_LIB_DIR="${PREFIX}/lib"
    export PYO3_CROSS_PYTHON_VERSION="${PY_VER}"
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY-worker.yml
# Also stages provenance and target-specific dependency notices. On macOS,
# upstream creates and ad-hoc signs the worker's AppKit helper bundle.
"${PYTHON}" bindings/python/stage_worker.py

cd bindings/python
cargo-bundle-licenses --format yaml --output THIRDPARTY-extension.yml
"${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation
