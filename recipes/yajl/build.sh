#!/bin/bash
set -ex

EXTRA_CMAKE_ARGS=""
if [[ `uname` == "Darwin" ]]; then
  EXTRA_CMAKE_ARGS="${EXTRA_CMAKE_ARGS} -DCMAKE_MACOSX_RPATH=ON"
fi

mkdir -p cmake-build
cd cmake-build

cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=${PREFIX} \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_INSTALL_RPATH=${PREFIX}/lib \
      -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" \
      ${EXTRA_CMAKE_ARGS} ${SRC_DIR}

make -j${CPU_COUNT}

make -j${CPU_COUNT} test

make -j${CPU_COUNT} install
