#!/bin/sh

# the lib and the bindings are separate cmake projects, this is fixed in master
mkdir -p build && cd build
cmake \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  ../src
make install -j${CPU_COUNT}

cd ..

mkdir -p build_py && pushd build_py
cmake \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  ../wrappers/pyAgrum
make install -j${CPU_COUNT}
