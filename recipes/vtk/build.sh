#!/bin/bash

BUILD_CONFIG=Release

mkdir build
cd build

if [ `uname` == Linux ]; then
    # FIXME refactor to reuse the python name (e.g. python3.5m)
    # FIXME detect any kind of suffix (m, or d)
    include_path=${PREFIX}/include/python${PY_VER}
    if [ ! -d $include_path ]; then
      # Control will enter here if $DIRECTORY doesn't exist.
      include_path=${PREFIX}/include/python${PY_VER}m
    fi

    PY_LIB="libpython${PY_VER}.so"
    library_file_path=${PREFIX}/lib/${PY_LIB}
    if [ ! -f $library_file_path ]; then
        library_file_path=${PREFIX}/lib/libpython${PY_VER}m.so
    fi

    cmake .. \
        -DCMAKE_BUILD_TYPE=$BUILD_CONFIG \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DCMAKE_INSTALL_RPATH:STRING="${PREFIX}/lib" \
        -DBUILD_DOCUMENTATION=OFF \
        -DBUILD_TESTING=ON \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_SHARED_LIBS=ON \
        -DVTK_WRAP_PYTHON=ON \
        -DPYTHON_EXECUTABLE=${PYTHON} \
        -DPYTHON_INCLUDE_PATH:PATH=$include_path \
        -DPYTHON_LIBRARY:FILEPATH=$library_file_path
fi

cmake --build . --target install --config $BUILD_CONFIG
