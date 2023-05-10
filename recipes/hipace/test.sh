#!/usr/bin/env bash

set -eu -x -o pipefail

export OMP_NUM_THREADS=2
export TEST_DIR=examples/beam_in_vacuum

# executable
impactx.NOMPI.NOACC.DP ${TEST_DIR}/inputs_SI

# ctest
if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
    ctest --test-dir build --output-on-failure
fi
