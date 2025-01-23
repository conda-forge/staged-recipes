#/usr/bin/env bash

set -ex

# Configure step
cmake -Bbuild -GNinja \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DPython_EXECUTABLE=${PYTHON} \
    -DBUILD_SHARED_LIBS=ON \
    -DMDI_Fortran=ON \
    -DMDI_Python=ON \
    -DMDI_CXX=ON

# Build step
cmake --build build -j${CPU_COUNT}
cmake --install build
