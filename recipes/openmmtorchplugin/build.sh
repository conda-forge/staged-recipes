#!/bin/bash

set -euxo pipefail

rm -rf build || true

CMAKE_FLAGS="  -DCMAKE_INSTALL_PREFIX=${PREFIX}"
CMAKE_FLAGS+=" -DCMAKE_BUILD_TYPE=Release"

CMAKE_FLAGS+=" -DBUILD_TESTING=ON"
CMAKE_FLAGS+=" -DOPENMM_DIR=${PREFIX}"
#CMAKE_FLAGS+=" -DPYTORCH_DIR="`${PYTHON} -c 'import torch; print(torch.utils.cmake_prefix_path)'`
CMAKE_FLAGS+=" -DPYTORCH_DIR=${SP_DIR}/torch"
# OpenCL
#CMAKE_FLAGS+=" -DNN_BUILD_OPENCL_LIB=OFF"
#CMAKE_FLAGS+=" -DOPENCL_INCLUDE_DIR=${PREFIX}/include"
#CMAKE_FLAGS+=" -DOPENCL_LIBRARY=${PREFIX}/lib/libOpenCL${SHLIB_EXT}"

# if CUDA_HOME is defined and not empty, we enable CUDA
if [[ -n ${CUDA_HOME-} ]]; then
    CMAKE_FLAGS+=" -DNN_BUILD_CUDA_LIB=ON"
fi

# Build in subdirectory and install.
mkdir -p build
cmake --version
cd build
cmake ${CMAKE_ARGS} ${CMAKE_FLAGS} ${SRC_DIR}
make -j$CPU_COUNT install

cp ${SRC_DIR}/python/myOpenMMSwigHeaders.i ${PREFIX}/include/swig/

make -j$CPU_COUNT PythonInstall

rm ${PREFIX}/include/swig/myOpenMMSwigHeaders.i

# Include test executables too
mkdir -p ${PREFIX}/share/${PKG_NAME}/tests
if [[ "$target_platform" == osx* ]]; then
    find . -name 'Test*' -perm +0111 -type f -exec cp {} ${PREFIX}/share/${PKG_NAME}/tests/ \;
else
    find . -name 'Test*' -executable -type f -exec cp {} ${PREFIX}/share/${PKG_NAME}/tests/ \;
fi
cp -r tests ${PREFIX}/share/${PKG_NAME}/tests/
ls -al ${PREFIX}/share/${PKG_NAME}/tests/
