#!/bin/bash

set -ex

cd python

export CMAKE_GENERATOR=Ninja
"${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation
