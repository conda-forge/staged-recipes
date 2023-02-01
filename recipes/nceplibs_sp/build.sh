#!/bin/bash

set -ex  # Abort on error.

mkdir build
cd build

cmake -G "Unix Makefiles" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH="${PREFIX}" \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} \
      "${SRC_DIR}"

make

make install
