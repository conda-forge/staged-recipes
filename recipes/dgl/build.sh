#!/bin/bash
set -euxo pipefail

rm -rf build || true


CUDA_CMAKE_OPTIONS="-DCMAKE_CUDA_COMPILER=${CUDA_HOME}/bin/nvcc -DCMAKE_CUDA_HOST_COMPILER=${CXX}"

# remove -std=c++17 from CXXFLAGS for compatibility with nvcc
export CXXFLAGS="$(echo $CXXFLAGS | sed -e 's/ -std=[^ ]*//')"

CMAKE_FLAGS="${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release -DPython_EXECUTABLE=${PYTHON}"

mkdir build
cd build
cmake -DUSE_CUDA=ON -DUSE_OPENMP=ON -DCUDA_ARCH_NAME=All ${CUDA_CMAKE_OPTIONS} ${CMAKE_FLAGS} ${SRC_DIR}
make -j$CPU_COUNT
cd ../python
${PYTHON} setup.py install --single-version-externally-managed --record=record.txt

# Fix some overlinking warnings/errors
ln -s $SP_DIR/dgl/libdgl.so $PREFIX/lib
