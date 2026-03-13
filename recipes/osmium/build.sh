#!/bin/bash

# Remove contrib folder as it contains libosmium and protozero
# which will be provided as conda dependencies
rm -rf contrib

# Set prefix for libosmium so CMake can find it
export LIBOSMIUM_PREFIX="${PREFIX}"
export PROTOZERO_PREFIX="${PREFIX}"

# Tell CMake to search conda environment first before system paths
export CMAKE_PREFIX_PATH="${PREFIX}"

# Build and install the package
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
