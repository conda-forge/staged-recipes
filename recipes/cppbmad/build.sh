#!/bin/bash

export ACC_ROOT_DIR=$BUILD_PREFIX

mkdir -p build
cd build

export FFLAGS="${FFLAGS} -I${PREFIX}/include/bmad"

cmake ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_PYBMAD=OFF \
  -DSKBUILD=OFF \
  -DVERSION_INFO="${PKG_VERSION}" \
  ..

make install # -j${CPU_COUNT}

echo "Moving python package from $PREFIX/pybmad to $SP_DIR/pybmad"
mkdir -p $SP_DIR
mv $PREFIX/pybmad $SP_DIR/
