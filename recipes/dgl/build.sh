#!/bin/bash
set -euxo pipefail

rm -rf build || true

CMAKE_FLAGS="${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release -DPython_EXECUTABLE=${PYTHON}"

git submodule init
git submodule update --recursive
mkdir build
cd build
cmake -DUSE_CUDA=$USE_CUDA -DUSE_OPENMP=ON -DCUDA_ARCH_NAME=All cmake ${CMAKE_FLAGS} ${SRC_DIR}
make -j$CPU_COUNT
cd ../python
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
