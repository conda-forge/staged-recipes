#!/usr/bin/env bash

set -ex

cmake -B _build -G Ninja -DBUILD_SHARED_LIBS=ON ${CMAKE_ARGS}
cmake --build _build
cmake --install _build
