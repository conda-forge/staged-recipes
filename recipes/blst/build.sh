#!/usr/bin/env bash

set -euxo pipefail

# C lib
bash ./build.sh -shared

# Install
mkdir -p "${PREFIX}"/lib
if [[ "${target_platform}" == osx-* ]]; then
  cp libblst.dylib "${PREFIX}"/lib
  cp libblst.dylib "${PREFIX}"/lib/libblst.."${PKG_MAJOR_VERSION}".dylib
  cp libblst.dylib "${PREFIX}"/lib/libblst.."${PKG_VERSION}".dylib
else
  cp libblst.so "${PREFIX}"/lib
  cp libblst.so "${PREFIX}"/lib/libblst.so."${PKG_MAJOR_VERSION}"
  cp libblst.so "${PREFIX}"/lib/libblst.so."${PKG_VERSION}"
fi

# Python bindings
pushd bindings/python
  export CXX="${CXX}"
  ./run.me
popd
