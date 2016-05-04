#!/bin/bash

mkdir build
cd build

if [ `uname` == Linux ]; then
    CC=${PREFIX}/bin/gcc
    CXX=${PREFIX}/bin/g++

    # FIXME refactor to reuse the python name (e.g. python3.5m)
    # FIXME detect any kind of suffix (m, or d)
    include_path=${PREFIX}/include/python${PY_VER}
    if [ ! -d $include_path ]; then
      # Control will enter here if $DIRECTORY doesn't exist.
              #-DCMAKE_INSTALL_PREFIX="${PREFIX}/lib/python{PY_VER}" \
      include_path=${PREFIX}/include/python${PY_VER}m
    fi

    PY_LIB="libpython${PY_VER}.so"
    library_file_path=${PREFIX}/lib/${PY_LIB}
    if [ ! -f $library_file_path ]; then
        library_file_path=${PREFIX}/lib/libpython${PY_VER}m.so
    fi

    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER=$CC \
        -DCMAKE_CXX_COMPILER=$CXX \
        -DBUILD_APPS=OFF \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DPYTHON_INCLUDE_PATH:PATH=$include_path \
        -DPYTHON_LIBRARY:FILEPATH=$library_file_path \
        -DPYTHON_INCLUDE_DIR=$include_path \
        -DPYTHONLIBS_VERSION_STRING="${PY_VER}"
fi

make -j${CPU_COUNT}
make install

# Copy openmesh.so back to \lib\python from \lib\python3.5
mv "${PREFIX}/lib/python/openmesh.so" "${PREFIX}/lib/python${PY_VER}/openmesh.so"