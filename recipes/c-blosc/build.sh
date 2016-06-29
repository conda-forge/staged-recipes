#!/bin/bash

mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_OSX_DEPLOYMENT_TARGET="" ..

cmake --build .
ctest
cmake --build . --target install
