#!/bin/bash

mkdir build
cd build

if [ "$(uname)" == "Linux" ]
then
    export SONAME='so'
    export CC=${PREFIX}/bin/gcc
    export CXX=${PREFIX}/bin/g++
else
    export SONAME='dylib'
    export CC=${PREFIX}/bin/clang
    export CXX=${PREFIX}/bin/clang++
fi

include_path=${PREFIX}/include/python${PY_VER}
if [ ! -d $include_path ];
then
  include_path=${PREFIX}/include/python${PY_VER}m
fi

PY_LIB="libpython${PY_VER}.{SONAME}"
library_file_path=${PREFIX}/lib/${PY_LIB}
if [ ! -f $library_file_path ];
then
    library_file_path=${PREFIX}/lib/libpython${PY_VER}m.{SONAME}
fi

cmake .. \
    -DCMAKE_C_COMPILER=$CC \
    -DCMAKE_CXX_COMPILER=$CXX "
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=$CC \
    -DCMAKE_CXX_COMPILER=$CXX \
    -DBUILD_APPS=OFF \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DPYTHON_INCLUDE_PATH:PATH=$include_path \
    -DPYTHON_LIBRARY:FILEPATH=$library_file_path \
    -DPYTHON_INCLUDE_DIR=$include_path \
    -DPYTHONLIBS_VERSION_STRING="${PY_VER}"

make install

# Copy openmesh.so back to \lib\python from \lib\python3.5
mv "${PREFIX}/lib/python/openmesh.so" "${PREFIX}/lib/python${PY_VER}/openmesh.so"