#!/bin/bash
set -ex

# Remove contrib folder as it contains libosmium and protozero
# which will be provided as conda dependencies
rm -rf contrib

# Build and install the package
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
