#!/bin/bash

set -xeuo pipefail

cd openmm-hip

mkdir build
pushd build

cmake ${CMAKE_ARGS} \
    -DCMAKE_MODULE_PATH:PATH=$PREFIX/lib/cmake/hip \
    -DOPENMM_DIR:PATH=${PREFIX} \
    -DOPENMM_SOURCE_DIR:PATH=${SRC_DIR}/openmm \
    ..

make -j${CPU_COUNT}

make install

# Fix some overlinking warnings/errors
for lib in ${PREFIX}/lib/plugins/libOpenMM*HIP*${SHLIB_EXT}; do
    ln -s $lib ${PREFIX}/lib/$(basename $lib) || true
done