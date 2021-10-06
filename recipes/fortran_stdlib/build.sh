#!/usr/bin/env bash
set -ex

cmake_options=(
  "-DCMAKE_INSTALL_PREFIX=${PREFIX}"
  "-DCMAKE_INSTALL_LIBDIR=lib"
  "-DBUILD_SHARED_LIBS=ON"
  "-GNinja"
)

cmake ${CMAKE_ARGS} "${cmake_options[@]}" -B _build
cmake --build _build
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == 0 ]]; then
  ctest --test-dir _build --output-on-failure --parallel
fi
cmake --install _build
