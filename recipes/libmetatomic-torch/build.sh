#!/usr/bin/env bash

set -eux

cmake -G Ninja $CMAKE_ARGS -DBUILD_SHARED_LIBS=ON .
cmake --build . --config Release --target install
