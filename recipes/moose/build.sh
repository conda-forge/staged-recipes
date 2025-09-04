#!/bin/bash
set -ex

# This is the standard command for installing a modern Python package in conda-build.
# It correctly handles all compiler and linker flags.
$PYTHON -m pip install . --no-deps -vv
