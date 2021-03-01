#!/bin/sh

# use conda-forge pybind11
rm -rf pybind11

$PYTHON -m pip install . -vv
