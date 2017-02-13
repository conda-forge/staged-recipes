#!/bin/bash
set -ex

# This flags come from project's travis build.
export CFLAGS="${CFLAGS} -fno-omit-frame-pointer -fstack-protector-all"
export CXXFLAGS="${CXXFLAGS} -fno-omit-frame-pointer -fstack-protector-all"

EXTRA_CMAKE_ARGS=""
if [[ `uname` == "Darwin" ]]; then
  EXTRA_CMAKE_ARGS="${EXTRA_CMAKE_ARGS} -DCMAKE_MACOSX_RPATH=ON"
fi

cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=${PREFIX} \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
      -DCMAKE_INSTALL_RPATH=${PREFIX}/lib \
      -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" \
      -DFORCE_IN_TREE_DEPENDENCIES="yes" \
      ${EXTRA_CMAKE_ARGS} ${SRC_DIR}

make -j${CPU_COUNT}
# The excluded tests take a long time to complete under CI and causes time out.
make -j${CPU_COUNT} test ARGS="-E 'random-data|threads' -V"
make -j${CPU_COUNT} install
