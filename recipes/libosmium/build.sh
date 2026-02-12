#! /bin/bash
set -e

cmake -B build \
  -S ${SRC_DIR} \
  ${CMAKE_ARGS} \
  -GNinja \
  -DWERROR=OFF \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build build -j ${CPU_COUNT}
ctest -V --test-dir build
cmake --install build