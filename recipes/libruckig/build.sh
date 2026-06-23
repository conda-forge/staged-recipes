#!/bin/sh

set -e

cmake -G Ninja ${CMAKE_ARGS} \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_CLOUD_CLIENT=OFF -DBUILD_TESTS=OFF \
  -S src \
  -B build_dir

cmake --build build_dir --config Release -- -j$CPU_COUNT
cmake --build build_dir --config Release --target install
