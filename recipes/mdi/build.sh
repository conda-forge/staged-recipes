#/usr/bin/env bash

set -ex

# Configure step
cmake -Bbuild -GNinja \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_Fortran_FLAGS="${FFLAGS}" \
    -DCMAKE_SHARED_LINKER_FLAGS="${LDFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    -DPython_EXECUTABLE=${PYTHON} \
    -DBUILD_SHARED_LIBS=ON \
    -DMDI_Fortran=ON \
    -DMDI_Python=ON \
    -DMDI_CXX=ON

# Build step
cmake --build build -j${CPU_COUNT}
cmake --install build
