#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S . -G Ninja -B build \
    -DWITH_LUA_ENGINE=LuaJIT \
    -DBUILD_SHARED_LIBS=ON \
    -DWITH_SHARED_LIBUV=ON \
    -DLUA_BUILD_TYPE=System \
    -DLUA_COMPAT53_DIR=${BUILD_PREFIX}/include/lua-compat-5.3 \
    -DBUILD_MODULE=ON \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
    -DCMAKE_BUILD_TYPE=Release

cmake --build build
cmake --install build
