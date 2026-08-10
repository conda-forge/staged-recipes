#!/bin/bash

set -exo pipefail

cmake -S . -B build -G Ninja \
	${CMAKE_ARGS} \
    -DTIMG_VERSION_FROM_GIT=OFF

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
