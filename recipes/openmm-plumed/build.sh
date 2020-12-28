#!/bin/bash

set -euxo pipefail

# Change Plumed's lepton's headers path temporarily
mv ${PREFIX}/include/plumed/lepton ${PREFIX}/include/plumed/lepton.bak || true

rm -rf build || true

CMAKE_FLAGS="  -DCMAKE_INSTALL_PREFIX=${PREFIX}"
CMAKE_FLAGS+=" -DCMAKE_BUILD_TYPE=Release"

CMAKE_FLAGS+=" -DBUILD_TESTING=ON"
CMAKE_FLAGS+=" -DOPENMM_DIR=${PREFIX}"
CMAKE_FLAGS+=" -DPLUMED_INCLUDE_DIR=${PREFIX}/include/plumed"
CMAKE_FLAGS+=" -DPLUMED_LIBRARY_DIR=${PREFIX}/lib"
# OpenCL
CMAKE_FLAGS+=" -DPLUMED_BUILD_OPENCL_LIB=ON"
CMAKE_FLAGS+=" -DOPENCL_INCLUDE_DIR=${PREFIX}/include"
CMAKE_FLAGS+=" -DOPENCL_LIBRARY=${PREFIX}/lib/libOpenCL${SHLIB_EXT}"

# if CUDA_HOME is defined and not empty, we enable CUDA
if [[ -n ${CUDA_HOME-} ]]; then
    CMAKE_FLAGS+=" -DCUDA_TOOLKIT_ROOT_DIR=${CUDA_HOME}"
    CMAKE_FLAGS+=" -DCMAKE_LIBRARY_PATH=${CUDA_HOME}/lib64/stubs"
    CMAKE_FLAGS+=" -DPLUMED_BUILD_CUDA_LIB=ON"
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

# Undo header relocation
test -d ${PREFIX}/include/plumed/lepton.bak && mv ${PREFIX}/include/plumed/lepton.bak ${PREFIX}/include/plumed/lepton

# Include test executables too
mkdir -p ${PREFIX}/share/openmm-plumed/tests
find . -name 'Test*' -perm +0111 -type f -exec cp {} ${PREFIX}/share/openmm-plumed/tests/ \;
