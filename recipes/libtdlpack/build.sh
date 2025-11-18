#!/bin/bash

set -ex # Abort on error.

declare -a CMAKE_PLATFORM_FLAGS
if [[ ${HOST} =~ .*darwin.* ]]; then
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
else
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
fi

echo "Building using ${PREFIX}"
echo "From ${PWD}"

mkdir build
cd build

# Make shared libs
cmake -G "${CMAKE_GENERATOR}" \
      "${CMAKE_ARGS}" \
      "${CMAKE_PLATFORM_FLAGS[@]}" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH="${PREFIX}" \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_FIND_FRAMEWORK=NEVER \
      -DCMAKE_FIND_APPBUNDLE=NEVER \
      -DBUILD_SHARED_LIBS=ON \
      -DBUILD_STATIC_LIBS=OFF \
      "${SRC_DIR}"

# Build
make

# Test
ctest -VV --output-on-failure -j"${CPU_COUNT}"

# Install
make install
