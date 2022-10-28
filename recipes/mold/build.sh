#!/bin/bash

set -ex
mkdir -p build-cpp
pushd build-cpp

cmake ${CMAKE_ARGS} .. \
    -GNinja \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
    -DMOLD_MOSTLY_STATIC=ON \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release 
cmake --build . -j $(nproc)
sudo cmake --install . --prefix $PREFIX
popd