#!/bin/bash
set -euxo pipefail

for triple in x86_64-w64-mingw32 aarch64-w64-mingw32; do
  arch=${triple%%-*}
  dest=$PREFIX/xclang/$triple
  case $arch in
    x86_64)  crt_libs="--disable-lib32 --enable-lib64" ;;
    aarch64) crt_libs="--disable-lib32 --disable-lib64 --enable-libarm64" ;;
  esac

  mkdir -p build-headers-$arch
  pushd build-headers-$arch
  ../mingw-w64-headers/configure \
    --host=$triple \
    --prefix=$dest \
    --enable-idl \
    --without-widl \
    --with-default-win32-winnt=0x603 \
    --with-default-msvcrt=ucrt
  make install
  popd

  export CC="clang --target=$triple --sysroot=$dest -isystem $dest/include"
  export AR=llvm-ar RANLIB=llvm-ranlib DLLTOOL=llvm-dlltool NM=llvm-nm STRIP=llvm-strip OBJCOPY=llvm-objcopy
  export LD="ld.lld"
  export RC="llvm-windres --target=$triple -I$dest/include"
  export WINDRES="$RC"

  mkdir -p build-crt-$arch
  pushd build-crt-$arch
  ../mingw-w64-crt/configure \
    --host=$triple \
    --prefix=$dest \
    $crt_libs \
    --with-default-msvcrt=ucrt \
    --enable-cfguard \
    --enable-silent-rules \
    --disable-dependency-tracking
  make -j${CPU_COUNT}
  make install
  popd

  mkdir -p build-winpthreads-$arch
  pushd build-winpthreads-$arch
  ../mingw-w64-libraries/winpthreads/configure \
    --host=$triple \
    --prefix=$dest \
    --enable-static \
    --disable-shared \
    CFLAGS="-O2" \
    LDFLAGS="-fuse-ld=lld"
  make -j${CPU_COUNT}
  make install
  popd

  unset CC AR RANLIB DLLTOOL NM STRIP OBJCOPY LD RC WINDRES
done
