#!/bin/bash

set -ex

python -m pip install . --no-build-isolation -v \
    --config-settings=cmake.args=-DODBDUMP_BIN_DIR="${PREFIX}"/bin \
    --config-settings=cmake.args=-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    --config-settings=cmake.args=-DCONDA_BUILD=ON