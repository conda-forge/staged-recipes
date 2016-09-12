#!/bin/sh

mkdir -p build && cd build

cmake \
  -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DBUILD_PYGMO=ON \
  -DENABLE_TESTS=ON \
  -DPYTHON_MODULES_DIR=${SP_DIR} \
  ..
make install -j${CPU_COUNT}
ctest --output-on-failure -j${CPU_COUNT}
