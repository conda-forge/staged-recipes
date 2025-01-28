#!/usr/bin/env bash

set -xe

cmake -S . -B build \
    -DMOTIF_INCLUDE_DIR=$PREFIX/include \
    -DPYTHON_EXECUTABLE:FILEPATH=$(which python3) \
    -DPYTHON_INCLUDE_DIR=$(python3 -c "import sysconfig; print(sysconfig.get_path('include'))")  \
    -DPYTHON_LIBRARY=$(python3 -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR'))") \
    ${CMAKE_ARGS}
cmake --build build --target install -j"${CPU_COUNT}"

