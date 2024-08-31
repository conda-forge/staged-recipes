#!/usr/bin/env bash

set -euxo pipefail

# C lib
if [[ "${target_platform}" == win-* ]]; then
  # Remove -fPIC from CFLAGS
  sed -i 's/-fPIC//g' build.sh
  bash ./build.sh -dll flavour=mingw64 CC=x86_64-w64-mingw32-gcc AR=llvm-ar
else
  bash ./build.sh -shared
fi

# Install
if [[ "${target_platform}" == win-* ]]; then
  cp blst-"${PKG_MAJOR_VERSION}".dll "${PREFIX}"/Library/bin
  cp blst-"${PKG_MAJOR_VERSION}".lib "${PREFIX}"/Library/lib
  cp blst-"${PKG_MAJOR_VERSION}".dll "${PREFIX}"/Library/bin/blst.dll
  cp blst-"${PKG_MAJOR_VERSION}".lib "${PREFIX}"/Library/lib/blst.lib
elif [[ "${target_platform}" == osx-* ]]; then
  mkdir -p "${PREFIX}"/lib
  cp libblst."${PKG_MAJOR_VERSION}".dylib "${PREFIX}"/lib
  ln -s "${PREFIX}"/lib/libblst."${PKG_MAJOR_VERSION}".dylib "${PREFIX}"/lib/libblst.dylib
  ln -s "${PREFIX}"/lib/libblst."${PKG_MAJOR_VERSION}".dylib "${PREFIX}"/lib/libblst."${PKG_VERSION}".dylib
else
  mkdir -p "${PREFIX}"/lib
  cp libblst.so."${PKG_MAJOR_VERSION}" "${PREFIX}"/lib
  ln -s "${PREFIX}"/lib/libblst.so."${PKG_MAJOR_VERSION}" "${PREFIX}"/lib/libblst.so
  ln -s "${PREFIX}"/lib/libblst.so."${PKG_MAJOR_VERSION}" "${PREFIX}"/lib/libblst.so."${PKG_VERSION}"
fi

# Headers
if [[ "${target_platform}" == win-* ]]; then
  mkdir -p "${PREFIX}"/Library/include
  cp bindings/blst.h "${PREFIX}"/Library/include
  cp bindings/blst_aux.h "${PREFIX}"/Library/include
else
  mkdir -p "${PREFIX}"/include
  cp bindings/blst.h "${PREFIX}"/include
  cp bindings/blst_aux.h "${PREFIX}"/include
fi

# libblst.pc
if [[ "${target_platform}" == win-* ]]; then
  pkgdir="${PREFIX}"/Library/lib/pkgconfig
else
  pkgdir="${PREFIX}"/lib/pkgconfig
fi
mkdir -p "${pkgdir}"
cat > "${pkgdir}"/libblst.pc <<EOF
fi
mkdir -p "${PREFIX}"/lib/pkgconfig
cat > "${PREFIX}"/lib/pkgconfig/libblst.pc <<EOF
prefix=${PREFIX}
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: libblst
Description: BLS12-381 signature library
Version: ${PKG_VERSION}
Libs: -L\${libdir} -lblst
Cflags: -I\${includedir}
EOF
ln -s "${pkgdir}"/libblst.pc "${pkgdir}"/blst.pc
