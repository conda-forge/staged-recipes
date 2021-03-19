#!/bin/bash

set -exuo pipefail

mkdir build
pushd build
export TBBROOT=${PREFIX}
export LDFLAGS="${LDFLAGS} -ltbb"
cmake ${CMAKE_ARGS} -GNinja \
  -DDNNL_CPU_RUNTIME=TBB \
  -DDNNL_GPU_RUNTIME=NONE \
  ..
ninja install
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != 1 ]]; then
  ninja test
fi
popd
