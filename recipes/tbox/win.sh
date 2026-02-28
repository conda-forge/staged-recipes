#!/bin/bash
set -euxo pipefail

cd "$SRC_DIR"

# Force clang toolchain for mingw platform detection
# configure hardcodes toolchains="x86_64_w64_mingw32" which probes for
# x86_64-w64-mingw32-gcc, but autotools_clang_conda provides clang/clang++
export CC=clang
export CXX=clang++
sed -i 's/        cc) toolname="gcc";;/        *-cc) toolname="clang";;\n        cc) toolname="clang";;/' configure
sed -i 's/        c++) toolname="gxx";;/        *-c++) toolname="clangxx";;\n        c++) toolname="clangxx";;/' configure
sed -i 's/toolchains="x86_64_w64_mingw32"/toolchains="clang"/' configure

./configure --generator=gmake --kind=shared --prefix="${PREFIX}"

patch_libtool
export REMOVE_LIB_PREFIX=1

make -j"${CPU_COUNT:-1}"
make install
