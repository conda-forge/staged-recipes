#!/bin/bash

mkdir build
cd build
cmake -DBUILD_PYTHON=OFF ..
cmake --build . -j%CPU_COUNT%

cmake --install . --prefix "%LIBRARY_PREFIX%"
