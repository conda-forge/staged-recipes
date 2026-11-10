#!/bin/bash
set -euxo pipefail

cmake -G Ninja -B _build -S "${RECIPE_DIR}" ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DLUAU_SOURCE_DIR="${SRC_DIR}" \
  -DLUAU_VERSION="${PKG_VERSION}" \
  -DLUAU_BUILD_CLI=ON \
  -DLUAU_BUILD_TESTS=OFF \
  -DLUAU_BUILD_WEB=OFF
cmake --build _build --parallel "${CPU_COUNT}"
cmake --install _build
