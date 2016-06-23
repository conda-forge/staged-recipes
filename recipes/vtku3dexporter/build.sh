#!/usr/bin/env bash
BUILD_CONFIG=Release

cd Samples/SampleCode

mkdir build
cd build

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
    -DPYTHON_INCLUDE_DIR:PATH=${PREFIX}/include \
    -DPYTHON_LIBRARY:FILEPATH=$library_file_path \
    -DCMAKE_BUILD_TYPE=$BUILD_CONFIG

make
