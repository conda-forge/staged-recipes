#!/usr/bin/env bash
set -ex

if [ "${mpi}" != "nompi" ]; then
  MPI=ON
else
  MPI=OFF
fi

cmake_options=(
   "-DCMAKE_INSTALL_PREFIX=${PREFIX}"
   "-DCMAKE_INSTALL_LIBDIR=lib"
   "-DBUILD_SHARED_LIBS=ON"
   "-DWITH_MPI=${MPI}"
   "-GNinja"
   ".."
)

mkdir -p _build
pushd _build
cmake "${cmake_options[@]}"

ninja all install

popd
