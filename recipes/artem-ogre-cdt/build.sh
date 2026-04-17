#!/bin/sh
set -ex

cmake -LAH -G "Ninja" \
  -B build ${CMAKE_ARGS} CDT
cmake --build build --target install
