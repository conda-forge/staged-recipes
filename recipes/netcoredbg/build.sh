#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ ${target_platform} =~ .*linux.* ]]; then
    sed -i 's/wait(int \*status)/wait(void *status)/' src/debugger/waitpid.cpp
fi

cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_TESTING=OFF \
    -DDOTNET_DIR=${DOTNET_ROOT} \
    ${CMAKE_ARGS}
cmake --build build -j${CPU_COUNT}
cmake --install build
