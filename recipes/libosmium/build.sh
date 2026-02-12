#! /bin/bash
set -e

cmake -B build -S ${SRC_DIR} ${CMAKE_ARGS} -GNinja -DWERROR=OFF
cmake --build -j ${CPU_COUNT} build
ctest -V --test-dir build
cmake --install build