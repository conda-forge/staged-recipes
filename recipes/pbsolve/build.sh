#!/usr/bin/env bash
set -euxo pipefail

# Licenses of all statically linked Rust crates (required by conda-forge).
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# cuda_compiler_version=12.x -> Cargo feature cuda-12 (13.x -> cuda-13).
if [[ "${cuda_compiler_version:-None}" != "None" ]]; then
  export MATURIN_PEP517_ARGS="--features cuda-${cuda_compiler_version%%.*}"
fi

"${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation
