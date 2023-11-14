#!/bin/bash

set -euxo pipefail

mkdir build
pushd build

cmake ${CMAKE_ARGS} -GNinja -DSIMDUTF_TOOLS=OFF -DBUILD_SHARED_LIBS=ON ..
ninja install

popd
