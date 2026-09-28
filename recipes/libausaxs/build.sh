#!/bin/bash
set -euxo pipefail

# Upstream defaults optimized x86-64 builds to -march=x86-64-v3 (AVX2). Build for the
# conda-forge x86-64 baseline instead; on other architectures "auto" selects the
# per-architecture default (e.g. armv8-a).
case "${target_platform}" in
  linux-64|osx-64) arch="x86-64" ;;
  *) arch="auto" ;;
esac

cmake ${CMAKE_ARGS} -S . -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DARCH="${arch}" \
  -DBUILD_TESTS=OFF \
  -DBUILD_EXECUTABLES=OFF \
  -DUSE_SYSTEM_DLIB=ON \
  -DUSE_SYSTEM_GCEM=ON \
  -DUSE_SYSTEM_BACKWARD=ON \
  -DUSE_SYSTEM_CLI11=ON \
  -DUSE_SYSTEM_THREADPOOL=OFF \
  -DFETCHCONTENT_SOURCE_DIR_THREAD_POOL="${SRC_DIR}/thread-pool" \
  -DFETCHCONTENT_FULLY_DISCONNECTED=ON

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
