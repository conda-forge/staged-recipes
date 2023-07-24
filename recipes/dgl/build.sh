#!/bin/bash
set -euxo pipefail

rm -rf build || true

if [ ${cuda_compiler_version} != "None" ]; then
CUDA_CMAKE_OPTIONS="-DCMAKE_CUDA_COMPILER=${CUDA_HOME}/bin/nvcc -DCMAKE_CUDA_HOST_COMPILER=${CXX}"
fi

# Remove -std=c++17 from CXXFLAGS for compatibility with nvcc
export CXXFLAGS="$(echo $CXXFLAGS | sed -e 's/ -std=[^ ]*//')"
export CFLAGS="$(echo $CFLAGS | sed -e 's/ -mtune=[^ ]*//')"
CMAKE_FLAGS="${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release -DPython_EXECUTABLE=${PYTHON}"

echo $CONDA_PREFIX

mkdir build
cd build

cmake -DUSE_CUDA=OFF \
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
  -DCUDA_ARCH_NAME=Turing \
  ${CMAKE_FLAGS} \
  ${CUDA_CMAKE_OPTIONS} \
  ${SRC_DIR}

make -j1 VERBOSE=1
cd ../python
${PYTHON} setup.py install --single-version-externally-managed --record=record.txt

# Fix some overlinking warnings/errors
ln -s $SP_DIR/dgl/libdgl.so $PREFIX/lib

