#!/bin/bash

set -euxo pipefail

mkdir -p build
cd build

CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=Release"
CMAKE_FLAGS+=" -DCMAKE_INSTALL_PREFIX=${PREFIX}"
CMAKE_FLAGS+=" -DOPENMM_DIR=${PREFIX}"
CMAKE_FLAGS+=" -DPYTHON_EXECUTABLE=${PYTHON}"
CMAKE_FLAGS+=" -DSWIG_EXECUTABLE=${PREFIX}/bin/swig"
# Every part is required: CMake stops with an error if one cannot be built, instead of leaving it out.
CMAKE_FLAGS+=" -DLBM_BUILD_OPENCL_LIB=ON"
CMAKE_FLAGS+=" -DLBM_BUILD_PYTHON_WRAPPERS=ON"
CMAKE_FLAGS+=" -DLBM_BUILD_HIP_LIB=OFF"
CMAKE_FLAGS+=" -DOPENMM_LBM_MPI=OFF"
if [[ "${cuda_compiler_version:-None}" != "None" ]]; then
    CMAKE_FLAGS+=" -DLBM_BUILD_CUDA_LIB=ON"
else
    CMAKE_FLAGS+=" -DLBM_BUILD_CUDA_LIB=OFF"
fi

cmake ${CMAKE_ARGS} ${CMAKE_FLAGS} "${SRC_DIR}"
make -j"${CPU_COUNT}"

# The C++ tests that need no GPU (serialization and Reference); the GPU platforms are tested on machines with a GPU.
ctest --output-on-failure -E "Cuda|OpenCL|Hip"

make install
make PythonInstall
