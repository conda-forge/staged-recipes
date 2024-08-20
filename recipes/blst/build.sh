#!/usr/bin/env bash

set -euxo pipefail

# C lib
bash ./build.sh -shared

# Install
mkdir -p "${PREFIX}"/lib
cp libblst.so "${PREFIX}"/lib
cp libblst.so "${PREFIX}"/lib/libblst.so."${PKG_MAJOR_VERSION}"
cp libblst.so "${PREFIX}"/lib/libblst.so."${PKG_VERSION}"

# Python bindings
pushd bindings/python
  export CXX="${CXX}"
  ./run.me
popd