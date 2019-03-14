#!/bin/bash
mkdir -p build
cd build

cmake .. \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
      -DCMAKE_BUILD_TYPE=Release

make -j$CPU_COOUNT

cp gemmi "$PREFIX/bin/"

cd $SRC_DIR

"$PYTHON" -m pip install . --no-deps -vv
