#!/bin/bash

## stopt

git clone https://gitlab.com/stochastic-control/StOpt
cd StOpt
mkdir build
cd build
cmake -DBUILD_PYTHON=OFF -DBUILD_TEST=OFF ..
cmake --build . -j $(nproc)
cmake --install . --prefix "$PREFIX"
cd ../..

# build SMS++
git submodule init
git submodule update

mkdir build
cd build
cmake ..
cmake --build . --config Release -j $(nproc)
cmake --install . --prefix "$PREFIX"
