#!/bin/bash

# Stop on first error
set -e

if [ "$(uname)" == "Darwin" ]; then
    # OSX
    g++ test.cpp -I"${PREFIX}/include" -L"${PREFIX}/lib" -laws-cpp-sdk-core -o test-core
    env DYLD_LIBRARY_PATH="${PREFIX}/lib:$DYLD_LIBRARY_PATH" ./test-core
else
    # Linux
    g++ test.cpp -I"${PREFIX}/include" -L"${PREFIX}/lib${ARCH}" -laws-cpp-sdk-core -o test-core
    env LD_LIBRARY_PATH="${PREFIX}/lib${ARCH}:$LD_LIBRARY_PATH" ./test-core
fi
