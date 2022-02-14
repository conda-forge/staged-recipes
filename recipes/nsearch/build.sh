#!/bin/bash

mkdir build
cd build

cmake -Wno-dev ..
cmake --build . --config Release

mkdir ${PREFIX}/bin
cp nsearch/nsearch ${PREFIX}/bin/nsearch