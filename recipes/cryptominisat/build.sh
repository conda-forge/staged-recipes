#!/bin/bash
set -eu -o pipefail

cd "$SRC_DIR"

mkdir -p build && cd build

if [[ $(uname) == 'Darwin' && $PY3K == 1 ]]; then
    export LDFLAGS="${LDFLAGS} -undefined dynamic_lookup -bundle"
else

# * ENABLE_PYTHON_INTERFACE: The Python interface expects Python3 (at least
#   that's what the Makefile seems to be checking for.)
# * ENABLE_TESTING: Testing requires lit which is not packaged yet:
#   https://github.com/conda-forge/staged-recipes/issues/4630
cmake \
  "-DCMAKE_INSTALL_PREFIX=$PREFIX" \
  -DENABLE_PYTHON_INTERFACE=`[[ $PY3K == 1 ]] && echo ON || echo OFF` \
  -DENABLE_TESTING=OFF \
  ..

make -j${CPU_COUNT} install

ln -s "$PREFIX/bin/cryptominisat5_simple" "$PREFIX/bin/cryptominisat_simple"
