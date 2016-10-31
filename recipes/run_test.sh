#!/bin/bash

# Stop on first error.
set -e

if [[ $(uname) == Darwin ]]; then
  export DYLD_LIBRARY_PATH=$PREFIX/lib
fi

pushd $SRC_DIR/tests

command -v mpiexec
mpiexec -mca plm isolated --allow-run-as-root -np 8 py.test

popd
