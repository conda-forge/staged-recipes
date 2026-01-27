#!/usr/bin/env bash
set -e

BUILD_DIR="build"

# osx-64 compatibility (https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk)
export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

# Ensure cstdlib is included to fix 'free' visibility issues with fmt library
export CXXFLAGS="${CXXFLAGS} -include cstdlib"

cd ${SRC_DIR}

mkdir -p ${BUILD_DIR}

rm -rf "contrib/"

cmake ${CMAKE_ARGS} -S . \
 -B ${BUILD_DIR} \
 -G "Ninja" \
 -D CMAKE_BUILD_TYPE=Release \
 -D EXTERNAL_LIBOSMIUM=ON \
 -D EXTERNAL_FMT=ON \
 -D EXTERNAL_CLI11=ON \
 -D EXTERNAL_PROTOZERO=ON \
 -D CMAKE_INSTALL_PREFIX="${PREFIX}" \
 -D CMAKE_FIND_FRAMEWORK=NEVER \
 -D CMAKE_FIND_APPBUNDLE=NEVER \
 -D CMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH=OFF \
 -D CMAKE_PREFIX_PATH="${PREFIX};${BUILD_PREFIX}" \
 -D LUA_INCLUDE_DIR="${PREFIX}/include" \
 -D LUA_LIBRARY="${PREFIX}/lib/liblua.dylib"

cmake --build ${BUILD_DIR} --target all

cmake --build ${BUILD_DIR} --target install


