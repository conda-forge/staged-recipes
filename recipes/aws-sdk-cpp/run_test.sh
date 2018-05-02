#!/bin/bash

# Stop on first error
set -e

if [ "$(uname)" == "Darwin" ]; then
    # OSX
    clang++ test.cpp -I"${PREFIX}/include" -L"${PREFIX}/lib" -Wl,-rpath,"${PREFIX}/lib" -laws-cpp-sdk-core -o test-core
    ./test-core
else
    # Linux
    g++ test.cpp -I"${PREFIX}/include" -L"${PREFIX}/lib" -Wl,-rpath,"${PREFIX}/lib" -laws-cpp-sdk-core -o test-core
    ./test-core
fi
