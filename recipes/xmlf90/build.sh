#!/usr/bin/env bash
set -ex

cmake --version

cmake_options=(
   "-DBUILD_SHARED_LIBS=ON"
   "-GNinja"
)

mkdir _build
pushd _build
cmake ${CMAKE_ARGS} "${cmake_options[@]}" ..
ninja all install
popd

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" ]]; then
  exit 0
fi

