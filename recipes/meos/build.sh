#!/bin/bash
set -e

if [[ "$target_platform" == linux* ]]; then
    sed -i "s,/usr/local,${PREFIX},g" ./meos/CMakeLists.txt
    sed -i "s,/opt/homebrew,${PREFIX},g" ./meos/CMakeLists.txt
elif [[ "$target_platform" == osx* ]]; then
    sed -i "" "s,/usr/local,${PREFIX},g" ./meos/CMakeLists.txt
    sed -i "" "s,/opt/homebrew,${PREFIX},g" ./meos/CMakeLists.txt
    sed -i "" "s,#define HAVE_STRCHRNUL 1,//#define HAVE_STRCHRNUL 1,g" ./meos/postgres/pg_config.h
fi

mkdir -p build && cd build

if [[ "$target_platform" == linux* ]]; then
  cmake ${CMAKE_ARGS} \
        -D CMAKE_BUILD_TYPE=Release \
        -D CMAKE_INSTALL_PREFIX=${PREFIX} \
        -D CMAKE_INSTALL_LIBDIR=lib \
        -D MEOS=on \
        -D GSL_INCLUDE_DIR=${PREFIX}/include \
        -D GSL_LIBRARY=${PREFIX}/lib/libgsl.so \
        -D GSL_CBLAS_LIBRARY=${PREFIX}/lib/libgslcblas.so \
        -D PROJ_INCLUDE_DIRS=${PREFIX}/include \
        -D PROJ_LIBRARIES=${PREFIX}/lib/libproj.so \
        -D GEOS_INCLUDE_DIR=${PREFIX}/include \
        -D GEOS_LIBRARY=${PREFIX}/lib/libgeos_c.so \
        -D JSON-C_INCLUDE_DIRS=${PREFIX}/include/json-c \
        -D JSON-C_LIBRARIES=${PREFIX}/lib/libjson-c.so \
        ${SRC_DIR}
elif [[ "$target_platform" == osx* ]]; then
  cmake ${CMAKE_ARGS} \
        -D CMAKE_BUILD_TYPE=Release \
        -D CMAKE_INSTALL_PREFIX=${PREFIX} \
        -D CMAKE_INSTALL_LIBDIR=lib \
        -D MEOS=on \
        -D GSL_INCLUDE_DIR=${PREFIX}/include \
        -D GSL_LIBRARY=${PREFIX}/lib/libgsl.dylib \
        -D GSL_CBLAS_LIBRARY=${PREFIX}/lib/libgslcblas.dylib \
        -D PROJ_INCLUDE_DIRS=${PREFIX}/include \
        -D PROJ_LIBRARIES=${PREFIX}/lib/libproj.dylib \
        -D GEOS_INCLUDE_DIR=${PREFIX}/include \
        -D GEOS_LIBRARY=${PREFIX}/lib/libgeos_c.dylib \
        -D JSON-C_INCLUDE_DIRS=${PREFIX}/include/json-c \
        -D JSON-C_LIBRARIES=${PREFIX}/lib/libjson-c.dylib \
        ${SRC_DIR}
fi
make -j
make install