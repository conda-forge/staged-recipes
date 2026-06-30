#!/bin/bash
set -euxo pipefail

cd "${SRC_DIR}"

# autotools_clang_conda supplies clang targeting the MSVC ABI.
export CC=clang
export CXX=clang++
export CFLAGS="${CFLAGS} -DNOCRYPT -DNOGDI"
export CXXFLAGS="${CXXFLAGS} -DNOCRYPT -DNOGDI"

./configure \
    --generator=gmake \
    --plat=mingw \
    --toolchain=clang \
    --external=y \
    --runtime=lua \
    --readline=n \
    --curses=n \
    --prefix="${PREFIX}"

make -j"${CPU_COUNT:-1}"
make install
