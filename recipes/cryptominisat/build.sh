#!/bin/bash
set -eu -o pipefail

cd "$SRC_DIR"

mkdir -p build && cd build
cmake \
  "-DCMAKE_INSTALL_PREFIX=$PREFIX" \
  -DENABLE_PYTHON_INTERFACE=OFF \
  -DENABLE_TESTING=OFF \
  ..

make -j${CPU_COUNT} install

ln -s "$PREFIX/bin/cryptominisat5_simple" "$PREFIX/bin/cryptominisat_simple"
