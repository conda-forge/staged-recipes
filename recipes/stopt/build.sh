#!/bin/bash

mkdir build
cd build
cmake -DBUILD_PYTHON=OFF ..
cmake --build . -j $(nproc)

ctest -R MyTestForGlobal
if errorlevel 1 exit 1

cmake --install . --prefix "$PREFIX"
