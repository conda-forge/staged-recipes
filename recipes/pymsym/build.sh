#!/bin/bash

# Ensure the script exits upon failure
set -e

# Example of setting a custom CMake argument. Adjust as needed.
export SKBUILD_CONFIGURE_OPTIONS="-DCMAKE_INSTALL_PREFIX:PATH=$PREFIX"

# Invoke the Python build process
$PYTHON -m pip install . -vv --no-deps --no-build-isolation
