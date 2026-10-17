#!/usr/bin/env bash
set -euxo pipefail

build_jobs="${CPU_COUNT:-2}"
if ((build_jobs > 6)); then
  build_jobs=6
fi

# CMAKE_ARGS is intentionally expanded into CMake's argument vector.
# shellcheck disable=SC2086
cmake ${CMAKE_ARGS} -S . -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DPython_EXECUTABLE="${PYTHON}" \
  -DWITH_NATIVE_OPT=OFF \
  -DBUILD_TESTING=OFF
cmake --build build --target moto_pywrap_stub -j"${build_jobs}"
cmake --install build
