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
      -DENABLE_SHARED=ON \
      -DENABLE_STATIC=ON \
      ${EXTRA_CMAKE_ARGS} ${SRC_DIR}

make -j${CPU_COUNT}

# This is the same as `make test` when not using cmake.
./lzotest -mlzo -n2 -q ${SRC_DIR}/COPYING

make -j${CPU_COUNT} install
