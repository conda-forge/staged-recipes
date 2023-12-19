#!/usr/bin/env bash

set -eu -x -o pipefail

export OMP_NUM_THREADS=2

# Example
$PYTHON examples/track_plasma_fluid.py

# pytest
$PYTHON -m pytest -s -vvvv tests/
