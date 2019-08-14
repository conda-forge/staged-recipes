#!/bin/bash

mkdir build
pushd build
cmake -D CMAKE_INSTALL_PREFIX=$PREFIX ..
cmake --build . --target install
popd
