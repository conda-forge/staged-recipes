#!/bin/env bash

set -ex
system=$(uname -s)

mkdir -p build
pushd build

cmake ${CMAKE_ARGS} -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POSITION_INDEPENDENT_CODE=on \
    -DBUILD_SHARED_LIBS=on \
    -Digraph_LIBRARY=igraph \
    ..

cmake --build . --config Release --target libleidenalg -- -j${CPU_COUNT}
cmake --build . --config Release --target install -j${CPU_COUNT}

popd
