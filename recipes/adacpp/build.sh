#!/bin/bash

set -ex
# if darwin print sdk version
if [[ $(uname) == Darwin ]]; then
  echo $CMAKE_ARGS
  xcrun --show-sdk-version
fi

python -m pip install . --no-build-isolation -v \
    --config-settings=cmake.args=-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    --config-settings=cmake.args=-DBUILD_TESTING=ON