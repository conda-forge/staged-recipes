#!/usr/bin/env bash

set -eu -x -o pipefail

export OMP_NUM_THREADS=2
export TEST_DIR=examples/beam_in_vacuum

# executable
impactx.NOMPI.NOACC.DP ${TEST_DIR}/inputs_SI
