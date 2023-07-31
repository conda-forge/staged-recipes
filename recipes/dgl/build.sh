#!/bin/bash
set -euxo pipefail

rm -rf build || true

if [ ${cuda_compiler_version} != "None" ]; then
CUDA_CMAKE_OPTIONS="-DCMAKE_CUDA_COMPILER=${CUDA_HOME}/bin/nvcc -DCMAKE_CUDA_HOST_COMPILER=${CXX}"
USE_CUDA=ON
else
CUDA_CMAKE_OPTIONS=""
USE_CUDA=OFF
fi

# Remove -std=c++17 from CXXFLAGS for compatibility with nvcc
export CXXFLAGS="$(echo $CXXFLAGS | sed -e 's/ -std=[^ ]*//')"
export CFLAGS="$(echo $CFLAGS | sed -e 's/ -mtune=[^ ]*//')"
CMAKE_FLAGS="${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release -DPython_EXECUTABLE=${PYTHON}"
if [[ ${cuda_compiler_version} != "None" ]]; then
    if [[ ${cuda_compiler_version} == 9.0* ]]; then
        export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;7.0+PTX"
    elif [[ ${cuda_compiler_version} == 9.2* ]]; then
        export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0+PTX"
    elif [[ ${cuda_compiler_version} == 10.* ]]; then
        export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5+PTX"
    elif [[ ${cuda_compiler_version} == 11.0* ]]; then
        export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0+PTX"
    elif [[ ${cuda_compiler_version} == 11.1 ]]; then
        export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6+PTX"
    elif [[ ${cuda_compiler_version} == 11.2 ]]; then
        export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6+PTX"
    else
        echo "unsupported cuda version. edit build.sh"
        exit 1
    fi
fi
echo $CONDA_PREFIX

mkdir build
cd build

cmake -DUSE_CUDA=${USE_CUDA} \
  -DUSE_CONDA_INCLUDES=ON \
  -DEXTERNAL_DLPACK_PATH=${BUILD_PREFIX}/include \
  -DEXTERNAL_DMLC_PATH=${BUILD_PREFIX}/include \
  -DEXTERNAL_DMLC_LIB_PATH=${BUILD_PREFIX}/lib \
  -DEXTERNAL_PHMAP_PATH=${BUILD_PREFIX}/include \
  -DEXTERNAL_NANOFLANN_PATH=${BUILD_PREFIX}/include \
  -DEXTERNAL_METIS_PATH=${BUILD_PREFIX}/include \
  -DEXTERNAL_METIS_LIB_PATH=${BUILD_PREFIX}/lib \
  -DUSE_LIBXSMM=ON \
  -DUSE_OPENMP=ON \
  -DCUDA_ARCH_NAME=Maxwell \
  ${CMAKE_FLAGS} \
  ${CUDA_CMAKE_OPTIONS} \
  ${SRC_DIR}

make -j1
cd ../python
${PYTHON} setup.py install --single-version-externally-managed --record=record.txt

# Fix some overlinking warnings/errors
ln -s $SP_DIR/dgl/libdgl.so $PREFIX/lib

