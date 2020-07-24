#!/usr/bin/env bash
set -ex

cmake_options=(
   "-GNinja"
   "-DCMAKE_BUILD_TYPE=Release"
   "-DCMAKE_INSTALL_PREFIX=${PREFIX}"
   "-DBUILD_SHARED_LIBS=ON"
   "-DLAPACK_LIBRARIES='lapack;blas'"
   "-DWITH_API=ON"
   "-DWITH_SOCKETS=ON"
   "-DWITH_OMP=ON"
   "-DWITH_MPI=OFF"
   ".."
)

mkdir -p _build
pushd _build

cmake "${cmake_options[@]}"
ninja all install
