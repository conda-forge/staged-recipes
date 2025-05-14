#!/bin/bash

mkdir -p build && cd build

cmake ${CMAKE_ARGS} -D CMAKE_INSTALL_PREFIX=${PREFIX} \
      -D CMAKE_LIBRARY_PATH:FILEPATH="${PREFIX}/lib" \
      -D CMAKE_INCLUDE_PATH:FILEPATH="${PREFIX}/include" \
      -D CMAKE_Fortran_COMPILER=$FC \
      ${SRC_DIR}

make -j${CPU_COUNT} ${VERBOSE_CM}

make install -j${CPU_COUNT}

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
  ctest -VV --output-on-failure
fi
