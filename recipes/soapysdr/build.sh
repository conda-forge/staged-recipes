#!/usr/bin/env bash

set -ex

mkdir build
cd build

# enable components explicitly so we get build error when unsatisfied
cmake_config_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DLIB_SUFFIX=""
    -DPYTHON_EXECUTABLE=$PYTHON
    -DSOAPY_SDR_EXTVER=$PKG_BUILDNUM
    -DSOAPY_SDR_ROOT_ENV="CONDA_PREFIX"
    -DENABLE_APPS=ON
    -DENABLE_DOCS=OFF
    -DENABLE_LIBRARY=ON
    -DENABLE_PYTHON=ON
    -DENABLE_TESTS=ON
)

cmake .. "${cmake_config_args[@]}"
cmake --build . --config Release -- -j${CPU_COUNT}
ctest --output-on-failure
cmake --build . --config Release --target install
