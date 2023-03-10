#!/bin/bash

set -ex # Abort on error.

mkdir build
cd build

# Make shared libs
cmake -G "${CMAKE_GENERATOR}" \
      "${CMAKE_ARGS}" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH="${PREFIX}" \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_FIND_FRAMEWORK=NEVER \
      -DCMAKE_FIND_APPBUNDLE=NEVER \
      -DBUILD_SHARED_LIBS=ON \
      -DBUILD_d=ON \
      -DBUILD_4=ON \
      -DBUILD_8=ON \
      "${SRC_DIR}"
make
make install

SKIP=""

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest -VV --output-on-failure -j"${CPU_COUNT}" "${SKIP}"
fi
