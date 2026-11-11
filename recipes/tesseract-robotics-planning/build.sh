#!/bin/sh

set -e

mkdir -p src
tar xf source.tar.gz --strip-components=1 -C src

cmake -GNinja \
  ${CMAKE_ARGS} \
  -DBUILD_SHARED_LIBS=ON \
  -DTESSERACT_ENABLE_TESTING=OFF \
  -DTESSERACT_ENABLE_EXAMPLES=OFF \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  -S src \
  -B build_dir

cmake --build build_dir --config Release -- -j$CPU_COUNT
cmake --build build_dir --config Release --target install
