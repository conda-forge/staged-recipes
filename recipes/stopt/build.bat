#!/bin/bash

mkdir build
cd build
cmake -DBUILD_PYTHON=OFF -DBUILD_TEST=OFF ..
cmake --build . -j%CPU_COUNT%

ctest --test-dir . --output-on-failure -j%CPU_COUNT%
if errorlevel 1 exit 1

cmake --install . --prefix "%LIBRARY_PREFIX%"
