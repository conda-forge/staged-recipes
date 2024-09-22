#!/usr/bin/env bash

set -euxo pipefail

# C lib
if [[ "${target_platform}" == win-* ]]; then
  # Remove -fPIC from CFLAGS
  sed -i 's/-fPIC//g' build.sh
  B_ARGS=('-dll' 'flavour=mingw64' 'CC=x86_64-w64-mingw32-gcc' 'AR=llvm-ar')
elif [[ "${target_platform}" == linux-* ]]; then
  B_ARGS=('-shared' "-Wl,-soname=libblst.so")
else
  B_ARGS=('-shared')
fi

bash ./build.sh "${B_ARGS[@]}"

# Install
if [[ "${target_platform}" == win-* ]]; then
  mkdir -p "${PREFIX}"/Library/bin
  install -m755 blst.dll "${PREFIX}"/Library/bin/blst.dll

  dlltool \
    -d build/win64/blst.def\
    -l "${PREFIX}"/Library/lib/blst.lib \
    -D "${PREFIX}"/Library/bin/blst.dll

elif [[ "${target_platform}" == osx-* ]]; then
  mkdir -p "${PREFIX}"/lib
  install -m755 libblst.dylib "${PREFIX}"/lib/libblst.dylib
else
  mkdir -p "${PREFIX}"/lib
  install -m755 libblst.so "${PREFIX}"/lib/libblst.so
fi

# Headers
if [[ "${target_platform}" == win-* ]]; then
  mkdir -p "${PREFIX}"/Library/include
  install -m644 bindings/blst.h "${PREFIX}"/Library/include
  install -m644 bindings/blst_aux.h "${PREFIX}"/Library/include
else
  mkdir -p "${PREFIX}"/include
  install -m644 bindings/blst.h "${PREFIX}"/include
  install -m644 bindings/blst_aux.h "${PREFIX}"/include
fi

# libblst.pc
if [[ "${target_platform}" == win-* ]]; then
  pkgdir="${PREFIX}"/Library/lib/pkgconfig
else
  pkgdir="${PREFIX}"/lib/pkgconfig
fi
mkdir -p "${pkgdir}"

cat > libblst.pc <<EOF
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

install -m644 libblst.pc "${pkgdir}"/libblst.pc
install -m644 libblst.pc "${pkgdir}"/blst.pc
