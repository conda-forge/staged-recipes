#!/bin/bash

set -euxo pipefail

mkdir -p build
pushd build
cmake $CMAKE_ARGS -GNinja -DCMAKE_CXX_STANDARD=17 ..
ninja install
