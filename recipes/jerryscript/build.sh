#!/bin/bash
set -euxo pipefail

cmake -S "${SRC_DIR}" -B build ${CMAKE_ARGS} -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DJERRY_PROFILE=es.next \
    -DJERRY_EXTERNAL_CONTEXT=ON \
    -DJERRY_PORT=ON \
    -DJERRY_DEBUGGER=OFF \
    -DJERRY_SNAPSHOT_SAVE=OFF \
    -DJERRY_SNAPSHOT_EXEC=OFF \
    -DJERRY_CMDLINE=OFF \
    -DJERRY_TESTS=OFF \
    -DJERRY_MEM_STATS=OFF \
    -DJERRY_PARSER_STATS=OFF \
    -DJERRY_LINE_INFO=OFF \
    -DJERRY_LTO=OFF \
    -DJERRY_LIBC=OFF

cmake --build build --target install -j"${CPU_COUNT}"
