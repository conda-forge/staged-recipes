#!/usr/bin/env bash

set -eu -x -o pipefail

export OMP_NUM_THREADS=2


$PYTHON -m pytest tests/
