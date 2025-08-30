#!/bin/bash
set -ex

# This is the standard command for installing a modern Python package in conda-build
# We add cpp_std to ensure the compiler uses the C++20 standard
$PYTHON -m pip install . --no-deps -vv --config-settings=setup-args="-Dcpp_std=c++20"
