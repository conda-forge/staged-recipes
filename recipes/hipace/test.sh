#!/usr/bin/env bash

set -eu -x -o pipefail

export OMP_NUM_THREADS=2
export TEST_DIR=tests

# executable
${TEST_DIR}/beam_in_vacuum.SI.Serial.sh hipace.NOMPI.NOACC.DP.LF .
