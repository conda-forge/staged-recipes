#!/bin/bash
set -ex

mkdir build
cd build

if [[ ${cuda_compiler_version:-None} != "None" ]]; then
  cmake -G Ninja \
      ${CMAKE_ARGS} \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_CUDA_ARCHITECTURES=all \
      -DSKIP_DOCS=TRUE \
      ${SRC_DIR}
else
  cmake -G Ninja \
      ${CMAKE_ARGS} \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DSKIP_DOCS=TRUE \
      -DSKIP_CUDA_LIB=TRUE \
      ${SRC_DIR}
fi

cmake --build . --target install --verbose 
