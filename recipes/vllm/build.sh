#!/bin/bash -e
export MAX_JOBS=1
# needed to find libcrypt headers
export CPATH=${BUILD_PREFIX}/include

${PYTHON} -m pip install . --no-deps -vv --no-deps --no-build-isolation
