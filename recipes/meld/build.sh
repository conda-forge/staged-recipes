#!/bin/bash

set -euxo pipefail

rm -rf build || true

CMAKE_FLAGS="${CMAKE_ARGS}  -DCMAKE_INSTALL_PREFIX=${PREFIX}"
CMAKE_FLAGS+=" -DCMAKE_BUILD_TYPE=Release"
CMAKE_FLAGS+=" -DBUILD_TESTING=ON"
CMAKE_FLAGS+=" -DOPENMM_DIR=${PREFIX}"
CMAKE_FLAGS+=" -DCUDA_TOOLKIT_ROOT_DIR=${CUDA_HOME}"
CMAKE_FLAGS+=" -DCMAKE_LIBRARY_PATH=${CUDA_HOME}/lib64/stubs"
export EIGEN3_INCLUDE_DIR=${PREFIX}/include/eigen3

# Build openmm plugin in subdirectory and install.
mkdir -p build
cd build
cmake ${CMAKE_FLAGS} ${SRC_DIR}/plugin
make -j$CPU_COUNT install
make -j$CPU_COUNT PythonInstall

# Perform meld python install
cd ..
pip install . -vv
