#!/bin/bash
set -euxo pipefail

cd "$SRC_DIR"

# Force clang toolchain for mingw platform detection
# configure hardcodes toolchains="x86_64_w64_mingw32" which probes for
# x86_64-w64-mingw32-gcc, but autotools_clang_conda provides clang/clang++
export CC=clang
export CXX=clang++
export CFLAGS="$CFLAGS -DNOCRYPT -DNOGDI"
export CXXFLAGS="$CXXFLAGS -DNOCRYPT -DNOGDI"
sed -i 's/toolchains="x86_64_w64_mingw32"/toolchains="clang"/' configure
# Add llvm-ar to clang toolchain's ar toolset (ar may not exist, but llvm-ar does)
sed -i '/^toolchain "clang"/,/^toolchain_end/{s/set_toolset "ar" "ar"/set_toolset "ar" "llvm-ar" "ar"/}' configure
# Add llvm-ar to path_toolname recognition
sed -i '/        ar) toolname="ar";;/a\        llvm-ar) toolname="ar";;' configure

# Remove pthread and m from mingw syslinks — they don't exist on MSVC target
# (math is in CRT, threading via Windows APIs; ws2_32 is still needed)
sed -i 's/add_syslinks "ws2_32" "pthread" "m"/add_syslinks "ws2_32" "user32"/' src/xmake.sh
# Do not append "lib" prefix to library names on Windows, as MSVC does not use it
sed -i 's/^[[:space:]]*prefixname="lib"/prefixname=""/' configure

./configure --generator=gmake --kind=shared --prefix="${PREFIX}"

# Remove -fPIC from generated Makefile — unsupported on Windows MSVC target
sed -i 's/-fPIC//g' Makefile

make tbox -j"${CPU_COUNT:-1}"

BUILD_DIR="build/mingw/x86_64/release"

install -Dm755 "${BUILD_DIR}/libtbox.dll" "${PREFIX}/bin/tbox.dll"
install -Dm644 "${BUILD_DIR}/tbox.lib" "${PREFIX}/lib/tbox.lib"

mkdir -p "${PREFIX}/include"
cp -r src/tbox "${PREFIX}/include/"