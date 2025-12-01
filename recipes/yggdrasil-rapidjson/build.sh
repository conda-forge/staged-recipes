#!/bin/sh
set -euo pipefail

cmake -B build -S ${SRC_DIR} \
      -G "Ninja" \
      -D YGGDRASIL_RAPIDJSON_HAS_STDSTRING:BOOL=ON \
      -D YGGDRASIL_RAPIDJSON_BUILD_TESTS:BOOL=OFF \
      -D YGGDRASIL_RAPIDJSON_BUILD_EXAMPLES:BOOL=OFF \
      -D YGGDRASIL_RAPIDJSON_BUILD_DOC:BOOL=OFF \
      -D Python3_EXECUTABLE=$PYTHON \
      -D CMAKE_VERBOSE_MAKEFILE:BOOL=ON \
       ${CMAKE_ARGS}
cmake --build build -j${CPU_COUNT}
cmake --install build
