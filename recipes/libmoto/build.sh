#!/usr/bin/env bash
set -euxo pipefail

# CMAKE_ARGS is intentionally expanded into CMake's argument vector.
# shellcheck disable=SC2086
cmake ${CMAKE_ARGS} -S . -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DPython_EXECUTABLE="${PYTHON}" \
  -DWITH_NATIVE_OPT=OFF \
  -DBUILD_TESTING=OFF
cmake --build build --target moto_pywrap_stub --parallel "${CPU_COUNT}"
cmake --install build
