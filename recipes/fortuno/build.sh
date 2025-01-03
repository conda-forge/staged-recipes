#!/usr/bin/env bash
set -ex

if [ "${mpi}" == "nompi" ]; then
  MPI=OFF
else
  MPI=ON
fi

cmake_options=(
   ${CMAKE_ARGS}
   "-DFORTUNO_WITH_SERIAL=ON"
   "-DFORTUNO_WITH_MPI=${MPI}"
)

BUILD_DIR="_build"
FFLAGS="-fno-backtrace" cmake "${cmake_options[@]}" -GNinja -B ${BUILD_DIR}
cmake --build ${BUILD_DIR}
cmake --install ${BUILD_DIR}
ctest --test-dir ${BUILD_DIR}
