#!/usr/bin/env bash
set -ex

cmake_options=(
   "-GNinja"
   "-DCMAKE_BUILD_TYPE=Release"
   "-DCMAKE_INSTALL_PREFIX=${PREFIX}"
   "-DCMAKE_INSTALL_LIBDIR=lib"
   "-DBUILD_SHARED_LIBS=ON"
   ".."
)

mkdir -p _build
pushd _build

cmake "${cmake_options[@]}"

ninja all install
