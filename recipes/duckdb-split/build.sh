#!/bin/bash

set -euxo pipefail

mkdir -p build
pushd build
cmake ${CMAKE_ARGS} -GNinja -DCMAKE_INSTALL_PREFIX=$(pwd)/dist ..
ninja
ninja install
