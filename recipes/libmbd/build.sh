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
   "-DENABLE_SCALAPACK_MPI=${MPI}"
   ".."
)

mkdir -p _build
pushd _build
cmake "${cmake_options[@]}"

make all install -j

popd
