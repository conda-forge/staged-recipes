#!/usr/bin/env bash
# Builds q3map2 on Linux and macOS using the standalone CMake project in
# cmake on top of the extracted netradiant-custom sources ($SRC_DIR).
set -euxo pipefail

# Reproducible builds on macOS: don't record file modification times in
# static archives and the linker's debug map (ld64 / cctools)
export ZERO_AR_DATE=1

# Build from within the source tree, so object file paths stay relative
cp "${RECIPE_DIR}/cmake/CMakeLists.txt" "${SRC_DIR}/CMakeLists.txt"

# CMAKE_ARGS is provided by the conda-forge compiler activation (install
# prefix, find root paths, macOS deployment target, ...) and must stay
# unquoted so it is split into separate arguments.
# shellcheck disable=SC2086
cmake -S "${SRC_DIR}" -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DNETRADIANT_SOURCE_DIR="${SRC_DIR}" \
    -DQ3MAP2_VERSION_SUFFIX="${PKG_VERSION}"

cmake --build build --verbose
cmake --install build --strip
