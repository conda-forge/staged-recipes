#!/usr/bin/env bash

set -eu -x -o pipefail

# Example
$PYTHON examples/track_plasma_fluid.py

# pytest
$PYTHON -m pytest -s -vvvv tests/
