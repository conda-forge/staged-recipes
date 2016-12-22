#!/bin/bash

pushd $SRC_DIR/tests

if [ "$(uname)" == "Darwin" ]; then
    python -b -m pytest
fi

# Using 4 cores to trigger pencil tests. Ok, but a bit slow since CPU_COUNT=2
if [ "$(uname)" == "Linux" ]; then
    mpiexec -n 4 python -b -m pytest
fi

popd
