#!/usr/bin/env bash
set -ex

cmake_options=(
   "-DCMAKE_INSTALL_PREFIX=${PREFIX}"
   "-DCMAKE_INSTALL_LIBDIR=lib"
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
