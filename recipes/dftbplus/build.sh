#!/usr/bin/env bash
set -ex

cmake_options=(
   "-GNinja"
   "-DCMAKE_BUILD_TYPE=Release"
   "-DCMAKE_INSTALL_PREFIX=${PREFIX}"
   "-DCMAKE_INSTALL_LIBDIR=lib"
   "-DBUILD_SHARED_LIBS=ON"
   "-DCMAKE_TOOLCHAIN_FILE=../sys/gnu.cmake"
   "-DCMAKE_Fortran_COMPILER=${FC}"
   "-DCMAKE_Fortran_FLAGS=${FFLAGS}"
   "-DCMAKE_C_COMPILER=${CC}"
   "-DCMAKE_C_FLAGS=${CFLAGS}"
   ".."
)

mkdir -p _build
pushd _build

cmake "${cmake_options[@]}"

ninja all install
