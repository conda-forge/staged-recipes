#!/bin/bash

# Stop on first error.
set -e

if [[ $(uname) == Darwin ]]; then
  export DYLD_LIBRARY_PATH=$PREFIX/lib
fi

pushd $SRC_DIR/tests

command -v mpirun
mpirun -np 8 py.test

popd
