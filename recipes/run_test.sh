#!/bin/bash

# Stop on first error.
set -e

pushd $SRC_DIR/tests

mpirun --allow-run-as-root -np 8 py.test

popd
