#!/bin/bash

mkdir build
cd build
cmake -DBUILD_PYTHON=OFF ..
cmake --build . --config Release -j%CPU_COUNT%

cmake --install . --prefix "%LIBRARY_PREFIX%"
