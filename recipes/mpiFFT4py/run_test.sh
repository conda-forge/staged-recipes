#!/bin/bash

pushd $SRC_DIR/tests

mpiexec -n $CPU_COUNT python -b -m pytest

popd
