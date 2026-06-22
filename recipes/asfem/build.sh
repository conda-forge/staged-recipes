#!/usr/bin/env bash
set -ex

export MPI_DIR="${PREFIX}"
export PETSC_DIR="${PREFIX}"

sed -i.bak 's/ -march=native//g' CMakeLists.txt
sed -i.bak "s#\${CMAKE_CURRENT_SOURCE_DIR}/external/eigen#${PREFIX}/include/eigen3#g" CMakeLists.txt

cmake -S . -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  ${CMAKE_ARGS}
cmake --build build --parallel "${CPU_COUNT}"

install -Dm755 bin/asfem "${PREFIX}/bin/asfem"
mkdir -p "${PREFIX}/share/asfem"
cp -R examples test_input "${PREFIX}/share/asfem/"
