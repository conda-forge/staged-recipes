#!/usr/bin/env bash
set -euxo pipefail

export MPI_DIR="${PREFIX}"
export PETSC_DIR="${PREFIX}"

rm -rf external

sed -i.bak \
  -e "s#\"\${CMAKE_CURRENT_SOURCE_DIR}/external\"#\"${PREFIX}/include\"#g" \
  -e "s#\"\${CMAKE_CURRENT_SOURCE_DIR}/external/eigen\"#\"${PREFIX}/include/eigen3\"#g" \
  CMakeLists.txt

cmake ${CMAKE_ARGS} -S . -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DASFEM_ENABLE_NATIVE=OFF
cmake --build build --parallel "${CPU_COUNT}"
cmake --install build

install -d "${PREFIX}/share/asfem"
cp -R examples test_input "${PREFIX}/share/asfem/"
