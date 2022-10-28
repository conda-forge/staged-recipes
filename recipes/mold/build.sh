#!/bin/bash

set -ex
mkdir -p build-cpp
pushd build-cpp

cmake ${CMAKE_ARGS} .. \
    -GNinja \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} \
    -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} \
    -DCMAKE_BUILD_TYPE=Release \
    -DMOLD_USE_SYSTEM_TBB=ON \
    -DMOLD_USE_SYSTEM_MIMALLOC=ON \
    -DCMAKE_SKIP_INSTALL_RULES=OFF
cmake --build . -j $(nproc)
cmake --install . --verbose --prefix $PREFIX
popd