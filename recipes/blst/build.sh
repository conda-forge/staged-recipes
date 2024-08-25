#!/usr/bin/env bash

set -euxo pipefail

# C lib
if [[ "${target_platform}" == win-* ]]; then
  # Remove -fPIC from CFLAGS
  export CFLAGS="${CFLAGS//-fPIC/}"
  bash ./build.sh -dll flavour=mingw64 CC=x86_64-w64-mingw32-gcc AR=llvm-ar
else
  bash ./build.sh -shared
fi

# Install
mkdir -p "${PREFIX}"/lib
if [[ "${target_platform}" == osx-* ]]; then
  cp libblst."${PKG_MAJOR_VERSION}".dylib "${PREFIX}"/lib
  ln -s "${PREFIX}"/lib/libblst."${PKG_MAJOR_VERSION}".dylib "${PREFIX}"/lib/libblst.dylib
  ln -s "${PREFIX}"/lib/libblst."${PKG_MAJOR_VERSION}".dylib "${PREFIX}"/lib/libblst."${PKG_VERSION}".dylib
else
  cp libblst.so."${PKG_MAJOR_VERSION}" "${PREFIX}"/lib
  ln -s "${PREFIX}"/lib/libblst.so."${PKG_MAJOR_VERSION}" "${PREFIX}"/lib/libblst.so
  ln -s "${PREFIX}"/lib/libblst.so."${PKG_MAJOR_VERSION}" "${PREFIX}"/lib/libblst.so."${PKG_VERSION}"
fi

# Headers
mkdir -p "${PREFIX}"/include
cp bindings/blst.h "${PREFIX}"/include
cp bindings/blst_aux.h "${PREFIX}"/include

# Python bindings
pushd bindings/python
  export CXX="${CXX}"
  ./run.me
popd