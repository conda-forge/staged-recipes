#!/bin/bash

mkdir build
cd build
cmake -DBUILD_PYTHON=OFF ..
cmake --build . -j%CPU_COUNT%

ctest
if errorlevel 1 exit 1

cmake --install . --prefix "%LIBRARY_PREFIX%"
