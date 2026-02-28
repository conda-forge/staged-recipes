#!/bin/bash
set -euxo pipefail

cd "$SRC_DIR"

# Force clang toolchain for mingw platform detection
# configure hardcodes toolchains="x86_64_w64_mingw32" which probes for
# x86_64-w64-mingw32-gcc, but autotools_clang_conda provides clang/clang++
export CC=clang
export CXX=clang++
sed -i 's/toolchains="x86_64_w64_mingw32"/toolchains="clang"/' configure
# Add llvm-ar to clang toolchain's ar toolset (ar may not exist, but llvm-ar does)
sed -i '/^toolchain "clang"/,/^toolchain_end/{s/set_toolset "ar" "ar"/set_toolset "ar" "llvm-ar" "ar"/}' configure
# Add llvm-ar to path_toolname recognition
sed -i '/        ar) toolname="ar";;/a\        llvm-ar) toolname="ar";;' configure

./configure --generator=gmake --kind=shared --prefix="${PREFIX}"

# Remove -fPIC from generated Makefile — unsupported on Windows MSVC target
sed -i 's/-fPIC//g' Makefile

make -j"${CPU_COUNT:-1}"
make install
