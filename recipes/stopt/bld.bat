#!/bin/bash

mkdir build
cd build
cmake %CMAKE_ARGS% -DBUILD_PYTHON=OFF -DBUILD_TEST=OFF ..
cmake --build . --config Release -j%CPU_COUNT%

cmake --install . --prefix "%LIBRARY_PREFIX%"
