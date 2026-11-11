#!/bin/bash
set -ex

# Remove vendored carma so the conda-forge host package is used instead
rm -rf carma/

# Set include paths from conda-forge
export CPLUS_INCLUDE_PATH="${PREFIX}/include/carma:${PREFIX}/include:${CPLUS_INCLUDE_PATH}"
export LIBRARY_PATH="${PREFIX}/lib:${LIBRARY_PATH}"

# Build and install
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
