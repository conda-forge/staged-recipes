#!/bin/sh
set -euo pipefail

examples=("serialize" "yggdrasil" "units")

for example in ${examples[@]}; do
    echo "Building \"${example}\""
    if [ ! -d example/${example}/build ]; then
        mkdir example/${example}/build
    fi
    cd example/${example}/build
    cmake -G "Ninja" \
          -D CMAKE_VERBOSE_MAKEFILE:BOOL=ON \
          ..
    cmake --build . --config Debug
    
    echo "Running \"${example}\""
    ./${example}

    cd ../../..
done
