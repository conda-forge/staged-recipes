#!/bin/bash
set -ex

mkdir build
cd build

if [[ ${cuda_compiler_version:-None} != "None" ]]; then
  EXTRA_CMAKE_ARGS="-DCMAKE_CUDA_ARCHITECTURES=all"
else
  EXTRA_CMAKE_ARGS="-DSKIP_CUDA_LIB=TRUE"
fi

cmake -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DSKIP_DOCS=TRUE \
    ${EXTRA_CMAKE_ARGS} \
    ${SRC_DIR}

cmake --build . --target install --verbose 
