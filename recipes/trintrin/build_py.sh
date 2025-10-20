#!/bin/sh

cd ${SRC_DIR}/bindings

rm -rf build
mkdir build
cd build

env

cmake ${CMAKE_ARGS} -GNinja .. \
    -DPython_EXECUTABLE:PATH=$PYTHON \
    -DPython3_EXECUTABLE:PATH=$PYTHON \
    -DTRINTRIN_DETECT_ACTIVE_PYTHON_SITEPACKAGES:BOOL=ON

ninja -v
cmake --build . --config Release --target install
