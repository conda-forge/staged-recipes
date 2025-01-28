#!/usr/bin/env bash

set -xe

mkdir -p build
cd build
cmake .. \
    -DPYBIND11_FINDPYTHON=ON \
    -DPYTHON_EXECUTABLE:FILEPATH=$(which python3) \
    -DPYTHON_INCLUDE_DIR=$(python3 -c "import sysconfig; print(sysconfig.get_path('include'))")  \
    -DPYTHON_LIBRARY=$(python3 -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR'))") \
    -DUSE_VENDORED_PYBIND11=OFF \
    -DUSE_VENDORED_QUAZIP=ON \
    -DUSE_VENDORED_IGRAPH=ON \
    -DUSE_VENDORED_SPDLOG=OFF \
    -DHAL_VERSION_MAJOR=4 \
    -DHAL_VERSION_MINOR=4 \
    -DHAL_VERSION_PATCH=1 \
    -DZ3_LIBRARIES=${CONDA_PREFIX}/lib \
    -DZ3_INCLUDE_DIRS=${CONDA_PREFIX}/include \
    ${CMAKE_ARGS}
make -j"${CPU_COUNT}" install

