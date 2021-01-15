#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DUSE_MPI=OFF \
    ..

make -j${CPU_COUNT} install

if [[ "$mpi" != "nompi" ]]; then
     cd ..
     mkdir build_mpi
     cd build_mpi
     cmake \
         -DCMAKE_INSTALL_PREFIX=${PREFIX} \
         -DUSE_MPI=ON \
         ..

     make -j${CPU_COUNT} install
fi
