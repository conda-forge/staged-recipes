#!/bin/bash

set -ex # Abort on error.

# Build Python wheel
$PYTHON -m pip wheel -w ./wheel ./build/api/swig/python

# Install it
$PYTHON -m pip install ./wheel/bagPy-*.whl
