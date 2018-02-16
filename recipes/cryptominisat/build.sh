#!/bin/bash
set -eu -o pipefail

cd "$SRC_DIR"

mkdir -p build && cd build
cmake \
  "-DCMAKE_INSTALL_PREFIX=$PREFIX" \
  -DSTATICCOMPILE=ON \
  -DENABLE_PYTHON_INTERFACE=OFF \
  -DENABLE_TESTING=OFF \
  ..

export

make -j${CPU_COUNT} install VERBOSE=1

ln -s "$PREFIX/bin/cryptominisat5_simple" "$PREFIX/bin/cryptominisat_simple"
