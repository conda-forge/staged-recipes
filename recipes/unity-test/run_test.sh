#!/bin/bash

# Stop on first error
set -ex

# Try compiling example using CMake
mkdir build && cd build
cmake ../ -G "Ninja"
cmake --build . --config Release
./cmake_build_test