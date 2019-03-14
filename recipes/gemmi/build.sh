#!/bin/bash
mkdir -p build
cd build

cmake .. \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX

make -j$CPU_COOUNT

cp gemmi "$PREFIX/bin/"

"$PYTHON" -m pip install . --no-deps -vv
