#!/bin/bash

set -ex

mkdir build
cd build

cmake \
    ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DMCVERSION=${PKG_VERSION} \
    -DMCCODE_BUILD_CONDA_PKG=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_MCSTAS=ON \
    -DMCCODE_USE_LEGACY_DESTINATIONS=OFF \
    -DBUILD_TOOLS=ON \
    -DENABLE_COMPONENTS=ON \
    -DENSURE_MCPL=OFF \
    -DENSURE_NCRYSTAL=OFF \
    -DENABLE_CIF2HKL=OFF \
    -DENABLE_NEUTRONICS=OFF \
    -DPython3_EXECUTABLE="${PYTHON}" \
    ..


cmake --build . --config Release
cmake --build . --target install --config Release

#Data files will be provided in mcstas-data package instead:
# rm -rf ${PREFIX}/share/mcstas/resources/data
