#!/bin/bash

set -exuo pipefail

export PYPI_RELEASE=1
export CMAKE_GENERATOR=Ninja
export BLAS_HOME=$PREFIX
if [[ "${target_platform}" != "osx-arm64" ]]; then
  export CMAKE_ARGS="${CMAKE_ARGS} -DMLX_BUILD_METAL=OFF"
fi
$PYTHON -m pip install . -vv
