#!/usr/bin/env bash
# some ideas from https://github.com/conda-forge/mapd-core-cpu-feedstock

set -ex

export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"

# Enforce PREFIX instead of BUILD_PREFIX:
# export ZLIB_ROOT=$PREFIX
# export LibArchive_ROOT=$PREFIX
# export Curses_ROOT=$PREFIX

# ./thirdparty/build-if-necessary.sh

# apply patches
# patch cmake_modules/FindGLog.cmake ${RECIPE_DIR}/patches/cmake_modules/FindGLog.cmake.patch

mkdir -p build/debug

cd build/debug

NO_REBUILD_THIRDPARTY=1 cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=debug \
  -DKUDU_USE_ASAN=1 \
  -DOPENSSL_ROOT_DIR=$PREFIX/bin/openssl \
  ../..

make -j $CPU_COUNT

ctest -j $CPU_COUNT

make DESTDIR=$PREFIX install
