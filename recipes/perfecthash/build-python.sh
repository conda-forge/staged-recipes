#!/usr/bin/env bash
set -euo pipefail

version_override="${PERFECTHASH_VERSION_OVERRIDE:-${PKG_VERSION:-${PERFECTHASH_CONDA_VERSION:-0.0.0}}}"

echo "==> Building PerfectHash Python package"
echo "==> Using version override: ${version_override}"

export PERFECTHASH_PYTHON_VERSION="${version_override}"
unset PERFECTHASH_PYTHON_NATIVE_ROOT

"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv

