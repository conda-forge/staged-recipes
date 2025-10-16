#!/bin/sh
set -euo pipefail

# Using cmake
if [ ! -d conda_build ]; then
    mkdir conda_build
fi
cd conda_build
cmake ${CMAKE_ARGS} \
      -G "Ninja" \
      -D RAPIDJSON_HAS_STDSTRING:BOOL=ON \
      -D RAPIDJSON_BUILD_TESTS:BOOL=OFF \
      -D RAPIDJSON_BUILD_EXAMPLES:BOOL=OFF \
      -D RAPIDJSON_BUILD_DOC:BOOL=OFF \
      -D RAPIDJSON_YGGDRASIL:BOOL=ON \
      -D Python3_EXECUTABLE=$PYTHON \
      -D CMAKE_VERBOSE_MAKEFILE:BOOL=ON \
      ..

cmake --install .

cd ..
