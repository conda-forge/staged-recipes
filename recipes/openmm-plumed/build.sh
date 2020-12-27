#!/bin/bash

set -euxo pipefail

rm -rf build || true

CMAKE_FLAGS="  -DCMAKE_INSTALL_PREFIX=${PREFIX}"
CMAKE_FLAGS+=" -DCMAKE_BUILD_TYPE=Release"
# Temporarily enabled
CMAKE_FLAGS+=" -DBUILD_TESTING=ON"
CMAKE_FLAGS+=" -DOPENMM_DIR=${PREFIX}"
CMAKE_FLAGS+=" -DPLUMED_INCLUDE_DIR=${PREFIX}/include/plumed"
CMAKE_FLAGS+=" -DPLUMED_LIBRARY_DIR=${PREFIX}/lib"

# if CUDA_HOME is defined and not empty, we enable CUDA
if [[ -n ${CUDA_HOME-} ]]; then
    # This is not working for now
    CMAKE_FLAGS+=" -DCUDA_TOOLKIT_ROOT_DIR=${CUDA_HOME}"
    CMAKE_FLAGS+=" -DCMAKE_LIBRARY_PATH=${CUDA_HOME}/lib64/stubs"
    CMAKE_FLAGS+=" -DPLUMED_BUILD_CUDA_LIB=ON"
    CMAKE_FLAGS+=" -DPLUMED_BUILD_OPENCL_LIB=ON"
else
    # just for debugging; final package will ship all platforms
    CMAKE_FLAGS+=" -DPLUMED_BUILD_CUDA_LIB=OFF"
    CMAKE_FLAGS+=" -DPLUMED_BUILD_OPENCL_LIB=OFF"
fi

if [[ "$target_platform" == osx* ]]; then
    CMAKE_FLAGS+=" -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
    CMAKE_FLAGS+=" -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}"
fi

# Build in subdirectory and install.
mkdir -p build
cd build
cmake ${CMAKE_FLAGS} ${SRC_DIR}
make -j$CPU_COUNT install
make -j$CPU_COUNT PythonInstall
ctest --verbose
