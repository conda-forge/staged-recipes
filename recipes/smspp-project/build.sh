#!/bin/bash

# build SMS++
git submodule init
git submodule update

mkdir build
cd build
cmake ..
cmake --build . --config Release -j $(nproc)
cmake --install . --config Release --prefix "$PREFIX"
