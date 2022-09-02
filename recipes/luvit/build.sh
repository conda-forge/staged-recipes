#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -B build -S luv \
	-D CMAKE_INSTALL_PREFIX="${PREFIX}" \
	-D CMAKE_BUILD_TYPE=Release \
	-D BUILD_SHARED_LIBS=ON \
	-D BUILD_STATIC_LIBS=OFF \
	-D WITH_SHARED_LIBUV=ON \
	-D WITH_LUA_ENGINE=LuaJIT \
	-D LUA_BUILD_TYPE=System \
	-D LUA_COMPAT53_DIR="${PWD}/compat53" \
	"${CMAKE_ARGS[@]}"

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build --prefix "${PREFIX}"
