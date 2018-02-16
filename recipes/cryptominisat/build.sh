#!/bin/bash
set -eu -o pipefail

cd "$SRC_DIR"

mkdir -p build && cd build
cmake \
  "-DCMAKE_INSTALL_PREFIX=$PREFIX" \
  -DENABLE_PYTHON_INTERFACE=OFF \
  # Testing requires lit which is not packaged yet: https://github.com/conda-forge/staged-recipes/issues/4630
  -DENABLE_TESTING=OFF \
  ..

make -j${CPU_COUNT} install

ln -s "$PREFIX/bin/cryptominisat5_simple" "$PREFIX/bin/cryptominisat_simple"
