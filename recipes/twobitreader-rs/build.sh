#!/bin/bash
set -euxo pipefail

# Rust statically links every crate into the extension module, so the licences of those
# crates ship inside the binary and must be packaged alongside our own.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

if [[ "${build_platform}" != "${target_platform}" ]]; then
  export PYO3_CROSS_INCLUDE_DIR="${PREFIX}/include"
  export PYO3_CROSS_LIB_DIR="${SP_DIR}/.."
  export PYO3_CROSS_PYTHON_VERSION="${PY_VER}"
fi

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
