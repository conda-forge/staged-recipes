#!/bin/bash

mkdir build
cd build
cmake ${CMAKE_ARGS} -DBUILD_PYTHON=OFF -DBUILD_TEST=OFF ..
cmake --build . --config Release -j ${CPU_COUNT}

ctest -R MyTestForGlobal

cmake --install . --prefix "$PREFIX"
