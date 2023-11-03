#!/bin/bash

set -ex

mkdir build
cd build

cmake -G "Unix Makefiles" \
    ${CMAKE_ARGS} \
    -DMCVERSION="${PKG_VERSION}" \
    -DMCCODE_BUILD_CONDA_PKG=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_MCSTAS=ON \
    -DMCCODE_USE_LEGACY_DESTINATIONS=OFF \
    -DBUILD_TOOLS=ON \
    -DENABLE_COMPONENTS=ON \
    -DENSURE_MCPL=OFF \
    -DENSURE_NCRYSTAL=OFF \
    -DENABLE_CIF2HKL=OFF \
    -DENABLE_NEUTRONICS=OFF \
    -DPython3_EXECUTABLE="${PYTHON}" \
    "${SRC_DIR}"


cmake --build . --config Release
cmake --build . --target install --config Release

#Data files will be provided in mcstas-data package instead:
# rm -rf ${PREFIX}/share/mcstas/resources/data
