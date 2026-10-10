#!/bin/bash
set -euxo pipefail

cmake -S "${SRC_DIR}" -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_PREFIX_PATH="${PREFIX}" \
  -DADBC_ODBC_BUILD_TESTS=OFF \
  -DADBCBRIDGE_INSTALL_MANIFEST=ON
cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
