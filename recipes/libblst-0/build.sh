#!/usr/bin/env bash

set -euxo pipefail

# C lib
if [[ "${target_platform}" == win-* ]]; then
  # Remove -fPIC from CFLAGS
  sed -i 's/-fPIC//g' build.sh
  sed "s/LIBRARY blst/LIBRARY blst-${PKG_MAJOR_VERSION}/g" build/win64/blst.def > build/win64/blst-"${PKG_MAJOR_VERSION}".def
  bash ./build.sh -dll flavour=mingw64 CC=x86_64-w64-mingw32-gcc AR=llvm-ar
else
  bash ./build.sh -shared
fi

# Install
if [[ "${target_platform}" == win-* ]]; then
  cp blst-"${PKG_MAJOR_VERSION}".dll "${PREFIX}"/Library/bin
  cp blst-"${PKG_MAJOR_VERSION}".lib "${PREFIX}"/Library/lib

elif [[ "${target_platform}" == osx-* ]]; then
  mkdir -p "${PREFIX}"/lib
  cp libblst."${PKG_MAJOR_VERSION}".dylib "${PREFIX}"/lib
  ln -s "${PREFIX}"/lib/libblst."${PKG_MAJOR_VERSION}".dylib "${PREFIX}"/lib/libblst."${PKG_VERSION}".dylib

else
  mkdir -p "${PREFIX}"/lib
  cp libblst.so."${PKG_MAJOR_VERSION}" "${PREFIX}"/lib
  ln -s "${PREFIX}"/lib/libblst.so."${PKG_MAJOR_VERSION}" "${PREFIX}"/lib/libblst.so."${PKG_VERSION}"
fi
