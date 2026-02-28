#!/bin/bash
set -euxo pipefail

cd "$SRC_DIR"

# Force clang toolchain - autotools_clang_conda provides clang/clang++ binaries
# but conda's compiler activation sets CC to x86_64-w64-mingw32-gcc wrapper
export CC=clang
export CXX=clang++

./configure --generator=gmake --kind=shared --prefix="${PREFIX}"

patch_libtool
export REMOVE_LIB_PREFIX=1

make -j"${CPU_COUNT:-1}"
make install
