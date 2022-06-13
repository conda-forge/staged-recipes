#!/bin/sh

cd ${SRC_DIR}/bindings

rm -rf build
mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DPython3_EXECUTABLE:PATH=$PYTHON \
    -DYARP_COMPILE_BINDINGS:BOOL=ON \
    -DCREATE_PYTHON:BOOL=ON \
    -DYARP_PYTHON_PIP_METADATA_INSTALL:BOOL=ON \
    -DYARP_PYTHON_PIP_METADATA_INSTALLER=conda \
    -DYARP_DISABLE_VERSION_SOURCE:BOOL=ON

cmake --build . --config Release
cmake --build . --config Release --target install
