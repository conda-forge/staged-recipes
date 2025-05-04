#!/bin/bash

mkdir build
cd build
cmake ..
cmake --build . -j%CPU_COUNT%

cd ..

ctest
if errorlevel 1 exit 1

cd build

cmake --install . --prefix "%LIBRARY_PREFIX%"
