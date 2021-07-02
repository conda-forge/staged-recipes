#!/bin/sh

# Build and execute C++ test application using yaml-cpp4rkt
cd test/app
cmake -S . -B build -DCMAKE_PREFIX_PATH=$PREFIX
cmake --build build
./build/app
