#!/usr/bin/env bash

set -ex

cmake -B build_cmake -GNinja $CMAKE_ARGS

cmake --build build_cmake

# The build created lib/libira.dylib, but setup.py
# and the python module hard-code 'libira.so'.
# We rename the file to make the setup.py script work.
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macOS detected. Renaming libira.dylib to libira.so for compatibility."
    mv lib/libira.dylib lib/libira.so
fi

# Install the package using pip
# This will automatically call setup.py, which runs cmake
# The conda build environment provides cmake, ninja, compilers, and libraries
# (liblapack, libblas) in the PATH and via environment variables.
$PYTHON -m pip install . --no-deps --no-build-isolation -vv
