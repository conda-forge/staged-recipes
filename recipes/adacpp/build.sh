#!/bin/bash

set -ex

python -m pip install . --no-build-isolation -v \
    --config-settings=cmake.args=-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    --config-settings=cmake.args=-DBUILD_TESTING=ON