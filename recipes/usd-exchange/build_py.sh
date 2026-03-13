#!/usr/bin/env bash
set -euxo pipefail

cmake -E copy "${RECIPE_DIR}/python/CMakeLists.txt" "${SRC_DIR}/CMakeLists.txt"

cmake -S "${SRC_DIR}" -B build -G Ninja \
  ${CMAKE_ARGS} \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DPython_EXECUTABLE="${PYTHON}" \
  -DUSDEX_VERSION="${PKG_VERSION}"

cmake --build build -j"${CPU_COUNT}"
cmake --install build
