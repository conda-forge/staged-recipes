#!/bin/bash
set -ex

echo "Building ${PKG_NAME} version ${PKG_VERSION}"

cmake -B build \
    -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_CXX_SCAN_FOR_MODULES=OFF \
    -DHUIRA_TOOLS=ON \
    -DHUIRA_PYTHON=ON \
    -DHUIRA_NATIVE_ARCH=OFF \
    -DPython_EXECUTABLE="${PYTHON}" \
    -DFETCHCONTENT_SOURCE_DIR_PYBIND11="${SRC_DIR}/pybind11-src"

cmake --build build --parallel ${CPU_COUNT}

cmake --install build
