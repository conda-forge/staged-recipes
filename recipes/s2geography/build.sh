#!/bin/bash
set -e

mkdir build
cd build

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
  BUILD_TESTS="ON"
else
  BUILD_TESTS="OFF"
fi

cmake ${CMAKE_ARGS} \
      -DCMAKE_CXX_STANDARD=17 \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_BUILD_TYPE=Release \
      -DS2GEOGRAPHY_S2_SOURCE=CONDA \
      -DBUILD_SHARED_LIBS=ON \
      -DS2GEOGRAPHY_BUILD_EXAMPLES=OFF \
      -DS2GEOGRAPHY_BUILD_TESTS=$BUILD_TESTS \
      -DS2GEOGRAPHY_CODE_COVERAGE=OFF \
      $SRC_DIR

cmake --build . -- -j${CPU_COUNT}

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
  cmake --build . -- test
fi

cmake --build . -- install
