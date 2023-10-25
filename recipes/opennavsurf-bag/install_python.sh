#!/bin/bash

set -ex # Abort on error.

# Build Python wheel
WHEEL_DIR="./wheel-$($PYTHON -V | awk '{print $2;}')"
$PYTHON -m pip wheel -w $WHEEL_DIR ./build/api/swig/python

# Install it
$PYTHON -m pip install $WHEEL_DIR/bagPy-*.whl
