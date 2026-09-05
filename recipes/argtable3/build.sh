#!/usr/bin/env bash

set -ex

cmake -B _build -S . -G Ninja ${CMAKE_ARGS} -DBUILD_SHARED_LIBS=ON
cmake --build _build
cmake --install _build
