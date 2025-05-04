#!/bin/bash

mkdir build
cd build
cmake ..
cmake --build . -j $(nproc)

cd ..

ctest
if errorlevel 1 exit 1

cd build

cmake --install . --prefix "$PREFIX"
