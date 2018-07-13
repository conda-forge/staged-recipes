#!/bin/bash
set -ex

ls
mkdir build-dir
cd build-dir

# cmake \
#     -DCMAKE_BUILD_TYPE=release \
#     -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
#     -DCMAKE_INSTALL_LIBDIR="${PREFIX}/lib" \
#     -DPYTHON_EXECUTABLE="${PREFIX}" \
#     -DPYTHON_INCLUDE_DIR="${PREFIX}/include" \
#     -DPYTHON_LIBRARY="$PREFIX/lib/libpython${PY_VER}.so" \
#     -DLIBXML2_DIR="${PREFIX}" \
#     -DLIBXML2_INCLUDE_DIR="${PREFIX}/include/libxml2" \
#     -DLIBXML2_INCLUDE_DIRS"${PREFIX}/include/" \
#     -DLIBXML2_LIBRARY="${PREFIX}/lib/libxml2.so" \
#     -DCMAKE_MODULE_PATH="${RECIPE_DIR}:${CMAKE_MODULE_PATH}" \
#     ..

cmake \
    -DCMAKE_BUILD_TYPE=release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR="${PREFIX}/lib" \
    -DPYTHON_EXECUTABLE="${PREFIX}/bin/python" \
    -DPYTHON_INCLUDE_DIR="${PREFIX}/include" \
    -DPYTHON_LIBRARY="$PREFIX/lib/libpython${PY_VER}.so" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    ..

make -j${CPU_COUNT}

make install
