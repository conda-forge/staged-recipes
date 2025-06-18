#!/bin/bash

mkdir build && cd build
cmake ${SRC_DIR}                             \
    -DCMAKE_PREFIX_PATH=${PREFIX}    \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DASP_DEPS_DIR=${PREFIX}         \
    -DUSE_OPENEXR=OFF                \
    -DCMAKE_VERBOSE_MAKEFILE=ON
make -j${CPU_COUNT}
make install

