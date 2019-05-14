#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

set -x

find . -name '*.h' -exec sed -i 's@#include <attr/xattr.h>@#include <sys/xattr.h>@g' {} \;
find . -name '*.c' -exec sed -i 's@#include <attr/xattr.h>@#include <sys/xattr.h>@g' {} \;

mkdir build
cd build

declare -a CMAKE_PLATFORM_FLAGS
if [ "$(uname)" == "Linux" ]; then
    # Fix up CMake for using conda's sysroot
    # See https://docs.conda.io/projects/conda-build/en/latest/resources/compiler-tools.html?highlight=cmake#an-aside-on-cmake-and-sysroots
    CMAKE_PLATFORM_FLAGS+=("-DCMAKE_TOOLCHAIN_FILE=${RECIPE_DIR}/cross-linux.cmake")
else
    CMAKE_PLATFORM_FLAGS+=("-DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}")
    CMAKE_PLATFORM_FLAGS+=("-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}")
fi

cmake -LAH \
    "${CMAKE_PLATFORM_FLAGS[@]}" \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DPLUGIN_LFC=OFF \
    -DPLUGIN_RFIO=OFF \
    -DGTEST_LOCATION="${PREFIX}" \
    -DLIB_SUFFIX="" \
    -DUNIT_TESTS=ON \
    ..

make -j${CPU_COUNT}
ctest
make install
