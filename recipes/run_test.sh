#!/bin/bash

pushd $SRC_DIR/tests

# mpiexec -n 8 python -b -m pytest  ## Fails on osx
python -b -m pytest

popd
