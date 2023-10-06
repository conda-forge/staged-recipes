#!/bin/bash

mkdir build

declare -a CMAKE_PLATFORM_FLAGS
if [[ ${HOST} =~ .*darwin.* ]]; then
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
else
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
fi

cmake -B build -S "${SRC_DIR}" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${PREFIX}" ${CMAKE_PLATFORM_FLAGS[@]}
cmake --build build --config Release --parallel ${CPU_COUNT}

mkdir -p "${PREFIX}/bin"
cp build/gotm "${PREFIX}/bin/"

rm -r build
