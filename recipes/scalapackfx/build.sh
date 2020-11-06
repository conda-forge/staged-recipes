#!/usr/bin/env bash
set -ex

cmake_options=(
   "-DCMAKE_INSTALL_PREFIX=${PREFIX}"
   "-DCMAKE_INSTALL_LIBDIR=lib"
   "-DBUILD_SHARED_LIBS=ON"
   "-DLAPACK_LIBRARY=lapack;blas"
   "-DSCALAPACK_LIBRARY=scalapack"
   "-GNinja"
   ".."
)

mkdir -p _build
pushd _build
cmake "${cmake_options[@]}"

ninja all install

popd
