#!/usr/bin/env bash
set -e

BUILD_DIR="build"

cd ${SRC_DIR}

mkdir -p ${BUILD_DIR}

cmake -S osmium-tool \
 -B ${BUILD_DIR} \
 -G "Ninja" \
 -D CMAKE_BUILD_TYPE=Release \
 -D CMAKE_INSTALL_PREFIX="${PREFIX}"

cmake --build ${BUILD_DIR} --target all

cmake --build ${BUILD_DIR} --target install
