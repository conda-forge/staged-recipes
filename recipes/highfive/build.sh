#!/bin/bash

# make sure we use CONDA_BUILD_SYSROOT
# https://github.com/conda/conda-build/issues/3452#issuecomment-475397070
declare -a CMAKE_PLATFORM_FLAGS
if [[ ${target_platform} == "osx-64" ]]
then
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
fi

mkdir -p build && cd build

cmake \
    "${CMAKE_PLATFORM_FLAGS[@]}" \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DHIGHFIVE_USE_BOOST=OFF \
    ..

make install
