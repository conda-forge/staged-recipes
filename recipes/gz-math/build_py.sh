#!/bin/sh

cd ${SRC_DIR}/src/python_pybind11

rm -rf build
mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DUSE_SYSTEM_PATHS_FOR_PYTHON_INSTALLATION:BOOL=ON \
    -DPython3_EXECUTABLE:PATH=$PYTHON \
    -DPYTHON_EXECUTABLE:PATH=$PYTHON

cmake --build . --config Release
cmake --build . --config Release --target install
