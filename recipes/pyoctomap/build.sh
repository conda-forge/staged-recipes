#!/bin/bash
set -ex

# Link the existing conda-forge octomap package. Do not compile or vendor it.
# https://github.com/conda-forge/octomap-feedstock
test -f "${PREFIX}/include/octomap/octomap.h"

export PYOCTOMAP_SYSTEM_OCTOMAP=1

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
