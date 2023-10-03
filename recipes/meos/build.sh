#!/bin/bash

echo "PREFIX variable: ${PREFIX}"

sed -i "s,/usr/local,${PREFIX},g" ./meos/CMakeLists.txt

mkdir -p build && cd build

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
      -D GEOS_LIBRARY=${PREFIX}/lib/libgeos.so \
      -D JSON-C_INCLUDE_DIRS=${PREFIX}/include/json-c \
      -D JSON-C_LIBRARIES=${PREFIX}/lib/libjson-c.so \
      ${SRC_DIR}

make -j
make install