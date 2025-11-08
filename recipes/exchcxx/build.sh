#!/usr/bin/env bash

set -ex

cmake -B _build -G Ninja -DBUILD_SHARED_LIBS=ON -DCMAKE_REQUIRE_FIND_PACKAGE_Libxc=ON ${CMAKE_ARGS}
cmake --build _build
cmake --install _build
