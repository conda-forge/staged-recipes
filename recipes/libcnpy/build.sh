#!/bin/bash

set -exuo pipefail

mkdir -p build
pushd build
cmake ${CMAKE_ARGS} -GNinja ..
ninja install
popd
