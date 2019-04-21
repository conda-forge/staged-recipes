#!/usr/bin/env bash
# Enable bash strict mode
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

declare -a CMAKE_PLATFORM_FLAGS
if [ "$(uname)" == "Linux" ]; then
    # Fix up CMake for using conda's sysroot
    # See https://docs.conda.io/projects/conda-build/en/latest/resources/compiler-tools.html?highlight=cmake#an-aside-on-cmake-and-sysroots
    CMAKE_PLATFORM_FLAGS+=("-DCMAKE_TOOLCHAIN_FILE=${RECIPE_DIR}/cross-linux.cmake")
fi

mkdir -p build
cd build

cmake -LAH \
    ${CMAKE_PLATFORM_FLAGS[@]+"${CMAKE_PLATFORM_FLAGS[@]}"} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
    -DCMAKE_INSTALL_NAME_DIR="${PREFIX}/lib" \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    ../source


make -j${CPU_COUNT}

make install

ctest --output-on-failure
