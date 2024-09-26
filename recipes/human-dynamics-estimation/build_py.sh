#!/bin/sh

cd ${SRC_DIR}/bindings

rm -rf build
mkdir build
cd build

env

cmake ${CMAKE_ARGS} -GNinja .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DPython_EXECUTABLE:PATH=$PYTHON \
    -DPython3_EXECUTABLE:PATH=$PYTHON \
    -DHDE_DETECT_ACTIVE_PYTHON_SITEPACKAGES:BOOL=ON

ninja -v
cmake --build . --config Release --target install
