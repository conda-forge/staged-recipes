#!/usr/bin/env bash
# Enable bash strict mode
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

declare -a CMAKE_PLATFORM_FLAGS
if [ "$(uname)" == "Linux" ]; then
    CMAKE_PLATFORM_FLAGS+=("-DCMAKE_AR=${GCC_AR}")
    CMAKE_PLATFORM_FLAGS+=("-DCLANG_DEFAULT_LINKER=${LD_GOLD}")
    CMAKE_PLATFORM_FLAGS+=("-DDEFAULT_SYSROOT=${PREFIX}/${HOST}/sysroot")
    CMAKE_PLATFORM_FLAGS+=("-DRT_LIBRARY=${PREFIX}/${HOST}/sysroot/usr/lib/librt.so")

    # Fix up CMake for using conda's sysroot
    # See https://docs.conda.io/projects/conda-build/en/latest/resources/compiler-tools.html?highlight=cmake#an-aside-on-cmake-and-sysroots
    CMAKE_PLATFORM_FLAGS+=("-DCMAKE_TOOLCHAIN_FILE=${RECIPE_DIR}/cross-linux.cmake")

else
    CMAKE_PLATFORM_FLAGS+=("-Dcocoa=ON")
    CMAKE_PLATFORM_FLAGS+=("-DCLANG_RESOURCE_DIR_VERSION='5.0.0'")
fi


mkdir -p build
cd build

cmake -LAH \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
    -DCMAKE_INSTALL_NAME_DIR="${PREFIX}/lib" \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    ../source 


make -j${CPU_COUNT}

#ctest

make install
