#!/usr/bin/env bash

set -eu -x -o pipefail

export OMP_NUM_THREADS=2
export TEST_DIR=examples/fodo

# executable
impactx.NOMPI.NOACC.DP ${TEST_DIR}/input_fodo.in

# Python
$PYTHON ${TEST_DIR}/run_fodo.py
