#!/bin/bash

set -euxo pipefail

cmake $CMAKE_ARGS -GNinja -B build
cmake --build build
cmake --install build
$PYTHON ./setup.py bdist_wheel
$PYTHON -m pip install dist/pulsar*.whl
