#!/bin/bash

set -ex

pushd . && mkdir build && cd build

# https://conda-forge.org/blog/posts/2020-10-29-macos-arm64/
cmake ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release ..

cmake --build . --config Release
if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
    cmake --build . --config Release --target test
fi
cmake --build . --config Release --target install

popd && rm -rf build
