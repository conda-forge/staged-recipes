#!/bin/bash

set -euxo pipefail
rm -rf build || true
mkdir build
cd build
CMAKE_FLAGS="${CMAKE_ARGS} -DCMAKE_PREFIX_PATH=${PREFIX} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release"
CMAKE_FLAGS+=" -DPython_EXECUTABLE=${PYTHON}"
CMAKE_FLAGS+=" -DCMAKE_VERBOSE_MAKEFILE=y"
CMAKE_FLAGS+=" -FETCHCONTENT_SOURCE_DIR_uammd=${SRC_DIR}/uammd-src"
CMAKE_FLAGS+=" -FETCHCONTENT_SOURCE_DIR_lanczos=${SRC_DIR}/lanczos-src"
CMAKE_FLAGS+=" -Dnanobind_DIR=$(${PYTHON} -c 'import sysconfig; print(sysconfig.get_paths()["purelib"])')/nanobind/cmake"
cmake ${SRC_DIR} ${CMAKE_FLAGS}
make install -j$CPU_COUNT
