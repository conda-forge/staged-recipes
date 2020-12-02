#!/bin/bash
set -e

cmake $SRC_DIR \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DTF_BUILD_EXAMPLES=OFF \
      -DTF_BUILD_TESTS=OFF \
      -DTF_BUILD_BENCHMARKS=OFF \
      -DTF_BUILD_CUDA=OFF \
      -DTF_BUILD_SYCL=OFF

make install
