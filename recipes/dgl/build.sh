#!/bin/bash
set -euxo pipefail

rm -rf build || true

CUDA_CMAKE_OPTIONS="-DCMAKE_CUDA_COMPILER=${CUDA_HOME}/bin/nvcc -DCMAKE_CUDA_HOST_COMPILER=${CXX}"

# Remove -std=c++17 from CXXFLAGS for compatibility with nvcc
export CXXFLAGS="$(echo $CXXFLAGS | sed -e 's/ -std=[^ ]*//')"

CMAKE_FLAGS="${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release -DPython_EXECUTABLE=${PYTHON}"

echo $CONDA_PREFIX

mkdir build
cd build

ls $PREFIX/include
ls $PREFIX/lib
ls $BUILD_PREFIX/include
ls $BUILD_PREFIX/lib

cmake -DUSE_CUDA=ON \
  -DUSE_CONDA_INCLUDES=OFF \
  -DEXTERNAL_DLPACK_PATH=$BUILD_PREFIX/include \
  -DEXTERNAL_DMLC_PATH=$BUILD_PREFIX/include \
  -DEXTERNAL_DMLC_LIB_PATH=$BUILD_PREFIX/lib \
  -DEXTERNAL_PHMAP_PATH=$BUILD_PREFIX/include \
  -DEXTERNAL_NANOFLANN_PATH=$BUILD_PREFIX/include \
  -DUSE_LIBXSMM=OFF \
  -DUSE_OPENMP=ON \
  -DCUDA_ARCH_NAME=All \
  ${CMAKE_FLAGS} \
  ${CUDA_CMAKE_OPTIONS} \
  ${SRC_DIR}

make -j$CPU_COUNT
cd ../python
${PYTHON} setup.py install --single-version-externally-managed --record=record.txt

# Fix some overlinking warnings/errors
ln -s $SP_DIR/dgl/libdgl.so $PREFIX/lib

