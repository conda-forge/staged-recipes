#!/bin/bash

git clone https://gitlab.com/stochastic-control/StOpt
cd StOpt
mkdir build
cd build
cmake -DBUILD_PYTHON=OFF -DBUILD_TEST=OFF ..
cmake --build . -j $(nproc)
cmake --install . --prefix "$PREFIX"
