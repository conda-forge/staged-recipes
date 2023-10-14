#!/bin/bash

mkdir build
pushd build

cmake ${CMAKE_ARGS} ..             \
    -GNinja                        \
    -DCMAKE_BUILD_TYPE=Release     \
    -DCMAKE_PREFIX_PATH=$PREFIX    \
    -DCMAKE_INSTALL_PREFIX=$PREFIX

cmake --build . --target install --parallel ${CPU_COUNT}

popd
