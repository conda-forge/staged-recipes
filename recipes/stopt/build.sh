#!/bin/bash

mkdir build
cd build
cmake -DBUILD_PYTHON=OFF -DBUILD_TEST=OFF ..
cmake --build . -j $(nproc)

cd ..

ctest
if errorlevel 1 exit 1

cd build

cmake --install . --prefix "$PREFIX"
