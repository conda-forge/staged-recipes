#!/bin/sh

set -e

export DONT_SET_MARCH=1
$PYTHON -m pip install . -vv --no-deps --no-build-isolation