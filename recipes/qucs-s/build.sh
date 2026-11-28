#!/bin/bash
# qucs-s build for conda-forge (linux-64 / linux-aarch64).
#
# qucsator_rf's CMakeLists searches hardcoded paths only (NO_DEFAULT_PATH);
# -DBISON_DIR points it at the build prefix's bison. gperf must be on PATH
# (build requirement).
set -ex

cmake -S . -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DBISON_DIR=$BUILD_PREFIX/bin \
  ${CMAKE_ARGS}

cmake --build build --parallel ${CPU_COUNT:-4}
cmake --install build
